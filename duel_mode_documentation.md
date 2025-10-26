# Tài Liệu Chi Tiết Về Duel Mode

## Tổng Quan

Duel Mode là chế độ chơi game memory match (ghép đôi thẻ Pokemon) giữa hai người chơi trực tuyến trong thời gian thực. Game sử dụng WebSocket để đảm bảo tính đồng bộ và trải nghiệm mượt mà.

## Kiến Trúc Hệ Thống

### Backend (Node.js + Express + MongoDB)

-   **Controllers**: Xử lý logic game và WebSocket events
-   **Services**: Quản lý matchmaking và trạng thái game
-   **Models**: Lưu trữ dữ liệu match, player và history
-   **Utils**: Tạo cards Pokemon ngẫu nhiên

### Frontend (Flutter)

-   **Services**: Quản lý kết nối WebSocket và trạng thái game
-   **Screens**: UI cho matchmaking và gameplay
-   **Widgets**: Components cho game board, player info, dialogs

## Logic Flow Chi Tiết

### 1. Matchmaking Process

```
Người chơi 1: join_queue → Thêm vào waiting queue
Người chơi 2: join_queue → Thêm vào waiting queue

Khi queue.length >= 2:
  → Tạo match mới
  → Chọn 12 Pokemon ngẫu nhiên
  → Tạo 24 thẻ (12 cặp)
  → Random thứ tự thẻ
  → Gửi match_found cho cả hai
```

**WebSocket Events:**

-   `solo_duel:join_queue` → `solo_duel:match_found`
-   `solo_duel:leave_queue` → Rời khỏi queue

### 2. Ready Phase

```
Match Status: "ready"
Countdown: 60 giây

Cả hai người chơi phải set ready:
  → solo_duel:player_ready

Khi cả hai ready:
  → Status = "playing"
  → Bắt đầu game
  → Chọn ngẫu nhiên người đi trước
```

### 3. Gameplay Phase

```
Luật chơi:
- 24 thẻ Pokemon (12 cặp)
- Lượt chơi xen kẽ
- Mỗi lượt lật tối đa 2 thẻ
- Nếu match: +100 điểm, tiếp tục lượt
- Nếu không match: Chuyển lượt cho đối phương
```

**Card Flip Logic:**

```
Người chơi lật thẻ 1:
  → solo_duel:flip_card(cardIndex)
  → Server kiểm tra: isMatched? isFlipped? lượt hiện tại?

Người chơi lật thẻ 2:
  → Kiểm tra match
  → Nếu match: Đánh dấu matched, +điểm, tiếp tục lượt
  → Nếu không: Lật lại thẻ, chuyển lượt
```

### 4. Game Over Conditions

```
Khi tất cả thẻ đã matched:
  → Status = "completed"
  → Tính điểm: score = matchedCards * 100
  → Winner: Người có score cao hơn
  → Nếu hòa: Người matched nhiều thẻ hơn
  → Lưu history cho cả hai
```

## Data Models

### SoloDuelMatch

```javascript
{
  matchId: String (UUID),
  status: "waiting" | "ready" | "playing" | "completed" | "cancelled",
  players: [Player],
  cards: [Card],
  currentTurn: userId,
  flippedCards: [FlippedCard],
  winner: userId,
  startedAt: Date,
  finishedAt: Date
}
```

### Player

```javascript
{
  userId: ObjectId,
  username: String,
  score: Number,
  matchedCards: Number,
  isReady: Boolean,
  isConnected: Boolean,
  avatar: String
}
```

### Card

```javascript
{
  pokemonId: Number,
  pokemonName: String,
  isMatched: Boolean,
  matchedBy: userId,
  position: Number
}
```

### History

```javascript
{
  matchId: String,
  userId: ObjectId,
  opponentId: ObjectId,
  score: Number,
  opponentScore: Number,
  matchedCards: Number,
  isWin: Boolean,
  gameTime: Number (giây),
  datePlayed: Date
}
```

## WebSocket Events

### Client → Server

-   `solo_duel:join_queue`: Tham gia queue
-   `solo_duel:leave_queue`: Rời queue
-   `solo_duel:player_ready`: Sẵn sàng chơi
-   `solo_duel:flip_card`: Lật thẻ
-   `solo_duel:surrender`: Đầu hàng

### Server → Client

-   `solo_duel:queue_joined`: Đã tham gia queue
-   `solo_duel:match_found`: Tìm thấy đối thủ
-   `solo_duel:player_ready`: Người chơi sẵn sàng
-   `solo_duel:game_started`: Game bắt đầu
-   `solo_duel:card_flipped`: Thẻ được lật
-   `solo_duel:match_result`: Kết quả lật thẻ
-   `solo_duel:game_over`: Game kết thúc
-   `solo_duel:error`: Lỗi

## Game Rules

1. **Setup**: 12 Pokemon ngẫu nhiên tạo thành 24 thẻ
2. **Turns**: Xen kẽ, bắt đầu ngẫu nhiên
3. **Flipping**: Tối đa 2 thẻ mỗi lượt
4. **Matching**: Nếu 2 thẻ giống nhau → +100 điểm, tiếp tục lượt
5. **No Match**: Lật lại thẻ, chuyển lượt
6. **Scoring**: Điểm = số cặp matched × 100
7. **Winning**: Người có điểm cao hơn thắng

## Error Handling

-   **Not your turn**: Không phải lượt của bạn
-   **Card already matched**: Thẻ đã matched
-   **Card already flipped**: Thẻ đã lật trong lượt này
-   **Match not found**: Không tìm thấy trận đấu
-   **Player disconnected**: Người chơi mất kết nối

## Reconnection Logic

```
Nếu mất kết nối:
  → Lưu matchId vào local storage
  → Khi reconnect: Kiểm tra match active
  → Rejoin match nếu đang playing/ready
  → Timeout 30s nếu đối phương disconnect
```

## Performance Considerations

-   **Real-time sync**: WebSocket đảm bảo đồng bộ
-   **State management**: ValueNotifier cho UI updates
-   **Memory optimization**: Chỉ lưu match active
-   **Error recovery**: Auto-reconnect và state recovery

## Testing Scenarios

1. **Normal gameplay**: 2 players, complete match
2. **Disconnect handling**: One player disconnects
3. **Reconnection**: Player rejoins active match
4. **Timeout**: Ready phase timeout
5. **Surrender**: Player gives up
6. **Draw condition**: Equal scores

## Future Enhancements

-   **Power-ups**: Special abilities during gameplay
-   **Tournaments**: Multi-round competitions
-   **Spectator mode**: Watch ongoing matches
-   **Statistics**: Detailed player performance metrics</content>
    <parameter name="filePath">d:\source\Flutter\memory_match_game\duel_mode_documentation.md
