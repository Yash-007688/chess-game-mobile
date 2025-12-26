enum PieceType { pawn, rook, knight, bishop, queen, king }
enum PieceColor { white, black }

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  ChessPiece(this.type, this.color, {this.hasMoved = false});

  @override
  String toString() {
    return '${color.name}_${type.name}';
  }

  // Get the Unicode character for the piece
  String get symbol {
    if (color == PieceColor.white) {
      switch (type) {
        case PieceType.king: return '♔';
        case PieceType.queen: return '♕';
        case PieceType.rook: return '♖';
        case PieceType.bishop: return '♗';
        case PieceType.knight: return '♘';
        case PieceType.pawn: return '♙';
        default: return '';
      }
    } else {
      switch (type) {
        case PieceType.king: return '♚';
        case PieceType.queen: return '♛';
        case PieceType.rook: return '♜';
        case PieceType.bishop: return '♝';
        case PieceType.knight: return '♞';
        case PieceType.pawn: return '♟';
        default: return '';
      }
    }
  }

  ChessPiece copyWith({PieceType? type, PieceColor? color, bool? hasMoved}) {
    return ChessPiece(
      type ?? this.type,
      color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}