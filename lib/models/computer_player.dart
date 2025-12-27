import 'dart:math';
import 'chess_game.dart';
import 'chess_move.dart';
import 'piece.dart';

class ComputerPlayer {
  final Random _random = Random();
  
  ChessMove? getBestMove(ChessGame game) {
    // Get all possible moves for the computer player
    List<ChessMove> possibleMoves = game.getAllPossibleMoves();
    
    if (possibleMoves.isEmpty) {
      return null; // No moves available (checkmate or stalemate)
    }
    
    // Simple AI: Choose a random valid move
    // In a more advanced implementation, we could implement minimax algorithm
    return possibleMoves[_random.nextInt(possibleMoves.length)];
  }
  
  // A more sophisticated move selection based on piece values
  ChessMove? getBestMoveWithBasicEvaluation(ChessGame game) {
    List<ChessMove> possibleMoves = game.getAllPossibleMoves();
    
    if (possibleMoves.isEmpty) {
      return null;
    }
    
    PieceColor computerColor = game.currentPlayer;
    PieceColor opponentColor = computerColor.opponent;
    
    // Try to capture opponent's pieces if possible
    List<ChessMove> capturingMoves = [];
    List<ChessMove> otherMoves = [];
    
    for (ChessMove move in possibleMoves) {
      if (game.board.pieceAt(move.to) != null) {
        capturingMoves.add(move);
      } else {
        otherMoves.add(move);
      }
    }
    
    // If there are capturing moves, choose one randomly among them
    if (capturingMoves.isNotEmpty) {
      return capturingMoves[_random.nextInt(capturingMoves.length)];
    }
    
    // Otherwise, just choose a random move
    return possibleMoves[_random.nextInt(possibleMoves.length)];
  }
}