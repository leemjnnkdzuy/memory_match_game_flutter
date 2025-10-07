const SoloDuelMatch = require("../models/soloDuelMatchModel");

class GameStateService {
	async handleCardFlip(matchId, userId, cardIndex) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new Error("Match not found");
		}

		if (match.status !== "playing") {
			throw new Error("Match is not in playing state");
		}

		if (match.currentTurn !== userId) {
			throw new Error("Not your turn");
		}

		const card = match.cards[cardIndex];
		if (card.isMatched) {
			throw new Error("Card already matched");
		}

		const currentTurnFlips = match.flippedCards.filter(
			(fc) =>
				fc.flippedBy === userId && !match.cards[fc.cardIndex].isMatched
		);

		if (currentTurnFlips.length >= 2) {
			throw new Error("Already flipped 2 cards this turn");
		}

		match.flippedCards.push({
			cardIndex,
			flippedBy: userId,
			flippedAt: new Date(),
		});

		if (currentTurnFlips.length === 1) {
			const firstCardIndex = currentTurnFlips[0].cardIndex;
			const firstCard = match.cards[firstCardIndex];
			const secondCard = match.cards[cardIndex];

			if (firstCard.pokemonId === secondCard.pokemonId) {
				match.cards[firstCardIndex].isMatched = true;
				match.cards[firstCardIndex].matchedBy = userId;
				match.cards[cardIndex].isMatched = true;
				match.cards[cardIndex].matchedBy = userId;

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
					match.winner =
						player1.score > player2.score
							? player1.userId
							: player2.userId;
				}
			} else {
				match.currentTurn = match.players
					.find((p) => p.userId.toString() !== userId)
					.userId.toString();
			}
		}

		match.updatedAt = new Date();
		await match.save();

		return match;
	}

	async setPlayerReady(matchId, userId) {
		const match = await SoloDuelMatch.findOne({matchId});

		if (!match) {
			throw new Error("Match not found");
		}

		const player = match.players.find(
			(p) => p.userId.toString() === userId
		);
		if (!player) {
			throw new Error("Player not found in match");
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
			throw new Error("Match not found");
		}

		match.status = "cancelled";
		match.finishedAt = new Date();
		await match.save();

		return match;
	}
}

module.exports = new GameStateService();
