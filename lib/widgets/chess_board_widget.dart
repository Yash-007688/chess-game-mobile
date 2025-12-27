import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/chess_move.dart';
import '../models/chess_game.dart';
import 'chess_piece_widget.dart';
import 'chess_square_widget.dart';

class ChessBoardWidget extends StatefulWidget {
  final ChessGame game;
  final double boardSize;
  final Function()? onMoveMade;

  const ChessBoardWidget({
    Key? key,
    required this.game,
    this.boardSize = 480.0,
    this.onMoveMade,
  }) : super(key: key);

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  Position? _selectedPosition;
  List<Position> _validMoves = [];

  @override
  Widget build(BuildContext context) {
    final squareSize = widget.boardSize / 8;
    final board = widget.game.board;

    // Determine if the board should be flipped based on the current player
    bool shouldFlipBoard = widget.game.currentPlayer == PieceColor.black;

    return Container(
      width: widget.boardSize,
      height: widget.boardSize,
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Saddle brown frame
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF654321), // Darker brown border
          width: 8,
        ),
      ),
      child: Column(
        children: [
          // Board with coordinates
          Expanded(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                final row = index ~/ 8;
                final col = index % 8;
                
                // Determine the actual position based on whether the board is flipped
                int actualRow = shouldFlipBoard ? 7 - row : row;
                final position = Position(actualRow, col);
                
                final piece = board.pieceAt(position);
                final isSelected = _selectedPosition != null && 
                    Position(_selectedPosition!.row, _selectedPosition!.col) == position;
                final isValidMove = _validMoves.any((move) => move == position);

                return ChessSquareWidget(
                  piece: piece,
                  position: position,
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: (pos) => _handleSquareTap(pos, shouldFlipBoard),
                  squareSize: squareSize,
                );
              },
            ),
          ),
          // Show coordinate labels only when black is at the bottom (current player is black)
          if (shouldFlipBoard) // Only show coordinates when black is at the bottom
            Container(
              height: 25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(8, (col) {
                  // Show coordinates based on perspective
                  int displayCol = 7 - col; // Since board is flipped, show in reverse order
                  String fileLabel = String.fromCharCode('a'.codeUnitAt(0) + displayCol);
                  return Text(
                    fileLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  void _handleSquareTap(Position position, bool isFlipped) {
    // The position passed in is already the internal board position
    // since we pass the actual position from itemBuilder

    if (_selectedPosition == null) {
      // No piece currently selected - check if the tapped square has a piece belonging to the current player
      final piece = widget.game.board.pieceAt(position);
      if (piece != null && piece.color == widget.game.currentPlayer) {
        _selectPiece(position);
      }
    } else {
      // A piece is already selected
      if (_selectedPosition == position) {
        // Deselect the piece
        _deselectPiece();
      } else {
        // Check if this is a valid move
        final isValidMove = _validMoves.any((move) => move.row == position.row && move.col == position.col);
        
        if (isValidMove) {
          // Make the move
          final move = ChessMove(
            from: _selectedPosition!,
            to: position,
          );
          widget.game.makeMove(move);
          _deselectPiece();
          
          // Update UI
          setState(() {});
          
          // Call the callback if provided
          if (widget.onMoveMade != null) {
            widget.onMoveMade!();
          }
        } else {
          // Check if the tapped square has a piece belonging to the current player
          final piece = widget.game.board.pieceAt(position);
          if (piece != null && piece.color == widget.game.currentPlayer) {
            _selectPiece(position);
          } else {
            // Tapped on an empty square or opponent's piece without being a valid move
            _deselectPiece();
          }
        }
      }
    }
  }

  void _selectPiece(Position position) {
    setState(() {
      _selectedPosition = position;
      _validMoves = widget.game.getPossibleMovesForPiece(position)
          .map((move) => move.to)
          .toList();
    });
  }

  void _deselectPiece() {
    setState(() {
      _selectedPosition = null;
      _validMoves = [];
    });
  }
}