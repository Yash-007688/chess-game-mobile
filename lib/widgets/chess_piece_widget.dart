import 'package:flutter/material.dart';
import '../models/piece.dart';

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece? piece;
  final double size;

  const ChessPieceWidget({
    Key? key,
    required this.piece,
    this.size = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (piece == null) {
      return Container();
    }

    // Use more realistic colors instead of Unicode symbols
    String pieceSymbol = _getPieceSymbol(piece!);
    Color pieceColor = piece!.color == PieceColor.white 
        ? const Color(0xFFF5F5DC) // Beige for white pieces
        : const Color(0xFF8B4513); // Saddle brown for black pieces

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: pieceColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: piece!.color == PieceColor.white 
              ? const Color(0xFF8B4513) // Darker border for white pieces to make them more visible
              : Colors.brown.shade800,
          width: 2, // Thicker border
        ),
      ),
      child: Center(
        child: Text(
          pieceSymbol,
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.w600, // Bolder text
            color: piece!.color == PieceColor.white 
                ? const Color(0xFF8B4513) // Dark brown for white pieces to make them more visible
                : Colors.white,
          ),
        ),
      ),
    );
  }

  String _getPieceSymbol(ChessPiece piece) {
    // Using Unicode chess symbols but with more realistic styling
    switch (piece.type) {
      case PieceType.king:
        return piece.color == PieceColor.white ? '♔' : '♚';
      case PieceType.queen:
        return piece.color == PieceColor.white ? '♕' : '♛';
      case PieceType.rook:
        return piece.color == PieceColor.white ? '♖' : '♜';
      case PieceType.bishop:
        return piece.color == PieceColor.white ? '♗' : '♝';
      case PieceType.knight:
        return piece.color == PieceColor.white ? '♘' : '♞';
      case PieceType.pawn:
        return piece.color == PieceColor.white ? '♙' : '♟';
    }
  }
}