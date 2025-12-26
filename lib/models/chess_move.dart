import 'position.dart';
import 'piece.dart';

class ChessMove {
  final Position from;
  final Position to;
  final ChessPiece? capturedPiece;
  final PieceType? promotionType; // For pawn promotion

  ChessMove({
    required this.from,
    required this.to,
    this.capturedPiece,
    this.promotionType,
  });

  @override
  String toString() {
    return '${from.algebraic}${to.algebraic}';
  }
}