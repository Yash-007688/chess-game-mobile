import 'piece.dart';
import 'position.dart';

class ChessBoard {
  final List<List<ChessPiece?>> _squares = List.generate(
    8, 
    (index) => List<ChessPiece?>.filled(8, null),
    growable: false
  );

  ChessBoard() {
    _initializeBoard();
  }

  void _initializeBoard() {
    // Initialize pawns
    for (int col = 0; col < 8; col++) {
      _squares[1][col] = ChessPiece(PieceType.pawn, PieceColor.black);
      _squares[6][col] = ChessPiece(PieceType.pawn, PieceColor.white);
    }

    // Initialize other pieces
    _squares[0][0] = ChessPiece(PieceType.rook, PieceColor.black);
    _squares[0][1] = ChessPiece(PieceType.knight, PieceColor.black);
    _squares[0][2] = ChessPiece(PieceType.bishop, PieceColor.black);
    _squares[0][3] = ChessPiece(PieceType.queen, PieceColor.black);
    _squares[0][4] = ChessPiece(PieceType.king, PieceColor.black);
    _squares[0][5] = ChessPiece(PieceType.bishop, PieceColor.black);
    _squares[0][6] = ChessPiece(PieceType.knight, PieceColor.black);
    _squares[0][7] = ChessPiece(PieceType.rook, PieceColor.black);

    _squares[7][0] = ChessPiece(PieceType.rook, PieceColor.white);
    _squares[7][1] = ChessPiece(PieceType.knight, PieceColor.white);
    _squares[7][2] = ChessPiece(PieceType.bishop, PieceColor.white);
    _squares[7][3] = ChessPiece(PieceType.queen, PieceColor.white);
    _squares[7][4] = ChessPiece(PieceType.king, PieceColor.white);
    _squares[7][5] = ChessPiece(PieceType.bishop, PieceColor.white);
    _squares[7][6] = ChessPiece(PieceType.knight, PieceColor.white);
    _squares[7][7] = ChessPiece(PieceType.rook, PieceColor.white);
  }

  ChessPiece? pieceAt(Position position) {
    if (!position.inBounds) return null;
    return _squares[position.row][position.col];
  }

  void setPieceAt(Position position, ChessPiece? piece) {
    if (!position.inBounds) return;
    _squares[position.row][position.col] = piece;
  }

  void movePiece(Position from, Position to) {
    final piece = pieceAt(from);
    if (piece != null) {
      setPieceAt(to, piece.copyWith(hasMoved: true));
      setPieceAt(from, null);
    }
  }

  // Get a copy of the board
  ChessBoard copy() {
    final newBoard = ChessBoard.empty();
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _squares[row][col];
        if (piece != null) {
          newBoard._squares[row][col] = piece.copyWith();
        }
      }
    }
    return newBoard;
  }

  // Create an empty board (for copying)
  ChessBoard.empty();

  @override
  String toString() {
    final buffer = StringBuffer();
    for (int row = 7; row >= 0; row--) {
      buffer.writeln('${row + 1} ${_getRowString(row)}');
    }
    buffer.writeln('  a b c d e f g h');
    return buffer.toString();
  }

  String _getRowString(int row) {
    final rowStr = <String>[];
    for (int col = 0; col < 8; col++) {
      final piece = _squares[row][col];
      if (piece == null) {
        rowStr.add('_');
      } else {
        rowStr.add(piece.symbol);
      }
    }
    return rowStr.join(' ');
  }
}