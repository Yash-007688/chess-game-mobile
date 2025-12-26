class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  // Create position from algebraic notation (e.g., 'e4' -> Position(4, 4))
  Position.fromAlgebraic(String algebraic) 
    : row = int.parse(algebraic[1]) - 1, 
      col = algebraic.codeUnitAt(0) - 'a'.codeUnitAt(0);

  // Convert to algebraic notation (e.g., Position(4, 4) -> 'e4')
  String get algebraic => String.fromCharCode('a'.codeUnitAt(0) + col) + '${row + 1}';

  Position operator +(Position other) => Position(row + other.row, col + other.col);
  
  Position operator -(Position other) => Position(row - other.row, col - other.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => algebraic;

  // Check if position is within board bounds
  bool get inBounds => row >= 0 && row < 8 && col >= 0 && col < 8;

  // Get all possible directions for sliding pieces
  static List<Position> get slidingDirections => [
    Position(-1, 0),  // Up
    Position(1, 0),   // Down
    Position(0, -1),  // Left
    Position(0, 1),   // Right
    Position(-1, -1), // Up-left
    Position(-1, 1),  // Up-right
    Position(1, -1),  // Down-left
    Position(1, 1),   // Down-right
  ];

  // Get all possible knight move directions
  static List<Position> get knightDirections => [
    Position(-2, -1), Position(-2, 1),
    Position(-1, -2), Position(-1, 2),
    Position(1, -2), Position(1, 2),
    Position(2, -1), Position(2, 1),
  ];
}