import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/position.dart';
import 'chess_piece_widget.dart';

class ChessSquareWidget extends StatelessWidget {
  final ChessPiece? piece;
  final Position position;
  final bool isSelected;
  final bool isValidMove;
  final Function(Position) onTap;
  final double squareSize;

  const ChessSquareWidget({
    Key? key,
    required this.piece,
    required this.position,
    this.isSelected = false,
    this.isValidMove = false,
    required this.onTap,
    this.squareSize = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Realistic wood-like chess board colors
    Color backgroundColor = (position.row + position.col) % 2 == 0
        ? const Color(0xFFDDB88C) // Light wood color (beige/tan)
        : const Color(0xFFA66D4F); // Dark wood color (brown)

    // Highlight selected square
    if (isSelected) {
      backgroundColor = const Color(0xFF5DADE2).withOpacity(0.7); // Blue highlight
    } 
    // Highlight valid move square
    else if (isValidMove) {
      backgroundColor = const Color(0xFF27AE60).withOpacity(0.7); // Green highlight
    }

    return GestureDetector(
      onTap: () => onTap(position),
      child: Container(
        width: squareSize,
        height: squareSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: const Color(0xFF8B4513), // Saddle brown border
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Center(
          child: ChessPieceWidget(
            piece: piece,
            size: squareSize * 0.85,
          ),
        ),
      ),
    );
  }
}