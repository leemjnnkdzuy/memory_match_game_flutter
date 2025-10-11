const SoloDuelMatch = require("../models/soloDuelMatchModel");
const AppError = require("../utils/errors");

class GameStateService {
	async handleCardFlip(matchId, userId, cardIndex) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new AppError("Match not found", 404);
		}

		if (match.status !== "playing") {
			throw new AppError("Match is not in playing state", 400);
		}

		if (match.currentTurn !== userId) {
			throw new AppError("Not your turn", 403);
		}

		const card = match.cards[cardIndex];
		if (card.isMatched) {
			throw new AppError("Card already matched", 400);
		}

		const alreadyFlipped = match.flippedCards.some(
			(fc) => fc.cardIndex === cardIndex
		);
		if (alreadyFlipped) {
			throw new AppError("Card already flipped this turn", 400);
		}

		if (match.flippedCards.length >= 2) {
			throw new AppError("Already flipped 2 cards this turn", 400);
		}

		match.flippedCards.push({
			cardIndex,
			flippedBy: userId,
			flippedAt: new Date(),
		});

		if (match.flippedCards.length === 1) {
			match.updatedAt = new Date();
			await match.save();
			return match;
		}

		if (match.flippedCards.length === 2) {
			const firstCardIndex = match.flippedCards[0].cardIndex;
			const secondCardIndex = match.flippedCards[1].cardIndex;
			const firstCard = match.cards[firstCardIndex];
			const secondCard = match.cards[secondCardIndex];

			const isMatch = firstCard.pokemonId === secondCard.pokemonId;

			match.lastMatchResult = {
				cardIndices: [firstCardIndex, secondCardIndex],
				isMatch,
				processedAt: new Date(),
			};

			if (isMatch) {
				match.cards[firstCardIndex].isMatched = true;
				match.cards[firstCardIndex].matchedBy = userId;
				match.cards[secondCardIndex].isMatched = true;
				match.cards[secondCardIndex].matchedBy = userId;

				const player = match.players.find(
					(p) => p.userId.toString() === userId
				);
				player.score += 100;
				player.matchedCards += 1;
				player.lastPickTime = new Date();

				const allMatched = match.cards.every((c) => c.isMatched);
				if (allMatched) {
					match.status = "completed";
					match.finishedAt = new Date();

					const player1 = match.players[0];
					const player2 = match.players[1];

					if (player1.score > player2.score) {
						match.winner = player1.userId;
					} else if (player2.score > player1.score) {
						match.winner = player2.userId;
					} else {
						match.winner =
							player1.matchedCards <= player2.matchedCards
								? player1.userId
								: player2.userId;
					}
				}
			} else {
				const opponent = match.players.find(
					(p) => p.userId.toString() !== userId
				);
				match.currentTurn = opponent.userId.toString();
			}

			match.flippedCards = [];
		}

		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	async setPlayerReady(matchId, userId) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new AppError("Match not found", 404);
		}

		const player = match.players.find(
			(p) => p.userId.toString() === userId
		);
		if (!player) {
			throw new AppError("Player not found in match", 404);
		}

		player.isReady = true;

		if (match.players.every((p) => p.isReady)) {
			match.status = "playing";
			match.startedAt = new Date();
		}

		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	async getMatchState(matchId) {
		return await SoloDuelMatch.findOne({matchId})
			.populate("players.userId", "username avatar")
			.populate("winner", "username avatar");
	}

	async cancelMatch(matchId, reason = "Player disconnected") {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new AppError("Match not found", 404);
		}

		match.status = "cancelled";
		match.finishedAt = new Date();
		await match.save();

		return match;
	}

	async surrenderMatch(matchId, userId) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new AppError("Match not found", 404);
		}

		if (match.status !== "playing") {
			throw new AppError("Match is not in playing state", 400);
		}

		const surrenderingPlayer = match.players.find(
			(p) => p.userId.toString() === userId
		);
		const opponent = match.players.find(
			(p) => p.userId.toString() !== userId
		);

		if (!surrenderingPlayer) {
			throw new AppError("Player not found in match", 404);
		}

		match.status = "completed";
		match.finishedAt = new Date();
		match.winner = opponent.userId;

		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	async handlePlayerDisconnect(matchId, userId) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			return null;
		}

		if (match.status !== "playing" && match.status !== "ready") {
			return null;
		}

		const player = match.players.find(
			(p) => p.userId.toString() === userId
		);

		if (!player) {
			return null;
		}

		player.isConnected = false;
		player.disconnectedAt = new Date();
		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	async handlePlayerReconnect(matchId, userId, socketId) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new AppError("Match not found", 404);
		}

		const player = match.players.find(
			(p) => p.userId.toString() === userId
		);

		if (!player) {
			throw new AppError("Player not found in match", 404);
		}

		player.isConnected = true;
		player.disconnectedAt = null;
		player.socketId = socketId;
		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	async handleDisconnectTimeout(matchId, userId) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			return null;
		}

		const disconnectedPlayer = match.players.find(
			(p) => p.userId.toString() === userId
		);

		if (!disconnectedPlayer || disconnectedPlayer.isConnected) {
			return null;
		}

		const opponent = match.players.find(
			(p) => p.userId.toString() !== userId
		);

		match.status = "completed";
		match.finishedAt = new Date();
		match.winner = opponent.userId;
		match.updatedAt = new Date();
		await match.save();

		return match;
	}
}

module.exports = new GameStateService();
