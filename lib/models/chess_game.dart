import 'piece.dart';
import 'position.dart';
import 'chess_board.dart';
import 'chess_move.dart';
import 'timer.dart';

class ChessGame {
  ChessBoard board;
  PieceColor currentPlayer;
  bool gameOver;
  PieceColor? winner;
  List<ChessMove> moveHistory;
  ChessTimer timer;

  // Castling rights
  bool whiteKingSideCastle = true;
  bool whiteQueenSideCastle = true;
  bool blackKingSideCastle = true;
  bool blackQueenSideCastle = true;

  // En passant target
  Position? enPassantTarget;

  ChessGame({int timerMinutes = 10})
      : board = ChessBoard(),
        currentPlayer = PieceColor.white,
        gameOver = false,
        winner = null,
        moveHistory = [],
        timer = ChessTimer(timerMinutes, PieceColor.white);

  // Get all possible moves for the current player
  List<ChessMove> getAllPossibleMoves() {
    final moves = <ChessMove>[];
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row, col);
        final piece = board.pieceAt(position);
        
        if (piece != null && piece.color == currentPlayer) {
          final pieceMoves = getPossibleMovesForPiece(position);
          moves.addAll(pieceMoves);
        }
      }
    }
    
    return moves;
  }

  // Get possible moves for a specific piece
  List<ChessMove> getPossibleMovesForPiece(Position position) {
    final piece = board.pieceAt(position);
    if (piece == null || piece.color != currentPlayer) {
      return [];
    }

    final moves = <ChessMove>[];
    
    switch (piece.type) {
      case PieceType.pawn:
        moves.addAll(_getPawnMoves(position));
        break;
      case PieceType.rook:
        moves.addAll(_getRookMoves(position));
        break;
      case PieceType.knight:
        moves.addAll(_getKnightMoves(position));
        break;
      case PieceType.bishop:
        moves.addAll(_getBishopMoves(position));
        break;
      case PieceType.queen:
        moves.addAll(_getQueenMoves(position));
        break;
      case PieceType.king:
        moves.addAll(_getKingMoves(position));
        break;
    }

    // Filter out moves that would put or leave the king in check
    return moves.where((move) {
      final testBoard = _makeMoveOnBoard(board, move);
      return !_isKingInCheck(testBoard, currentPlayer);
    }).toList();
  }

  List<ChessMove> _getPawnMoves(Position position) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;
    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    // Move forward one square
    final oneStep = Position(position.row + direction, position.col);
    if (oneStep.inBounds && board.pieceAt(oneStep) == null) {
      moves.add(ChessMove(from: position, to: oneStep));
      
      // Move forward two squares from starting position
      final twoStep = Position(position.row + 2 * direction, position.col);
      if (position.row == startRow && board.pieceAt(twoStep) == null) {
        moves.add(ChessMove(from: position, to: twoStep));
      }
    }

    // Captures
    for (int colOffset in [-1, 1]) {
      final capturePos = Position(position.row + direction, position.col + colOffset);
      if (capturePos.inBounds) {
        final targetPiece = board.pieceAt(capturePos);
        if (targetPiece != null && targetPiece.color != piece.color) {
          moves.add(ChessMove(from: position, to: capturePos, capturedPiece: targetPiece));
        }
        
        // En passant capture
        if (enPassantTarget != null && capturePos == enPassantTarget) {
          final capturedPawnPos = Position(position.row, capturePos.col);
          final capturedPiece = board.pieceAt(capturedPawnPos);
          if (capturedPiece != null) {
            moves.add(ChessMove(from: position, to: capturePos, capturedPiece: capturedPiece));
          }
        }
      }
    }

    return moves;
  }

  List<ChessMove> _getRookMoves(Position position) {
    return _getSlidingMoves(position, [
      Position(-1, 0), Position(1, 0), Position(0, -1), Position(0, 1)
    ]);
  }

  List<ChessMove> _getBishopMoves(Position position) {
    return _getSlidingMoves(position, [
      Position(-1, -1), Position(-1, 1), Position(1, -1), Position(1, 1)
    ]);
  }

  List<ChessMove> _getQueenMoves(Position position) {
    return _getSlidingMoves(position, Position.slidingDirections);
  }

  List<ChessMove> _getKnightMoves(Position position) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;

    for (final direction in Position.knightDirections) {
      final target = position + direction;
      if (target.inBounds) {
        final targetPiece = board.pieceAt(target);
        if (targetPiece == null || targetPiece.color != piece.color) {
          moves.add(ChessMove(
            from: position,
            to: target,
            capturedPiece: targetPiece,
          ));
        }
      }
    }

    return moves;
  }

  List<ChessMove> _getKingMoves(Position position) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;

    // Standard king moves
    for (final direction in Position.slidingDirections) {
      final target = position + direction;
      if (target.inBounds) {
        final targetPiece = board.pieceAt(target);
        if (targetPiece == null || targetPiece.color != piece.color) {
          moves.add(ChessMove(
            from: position,
            to: target,
            capturedPiece: targetPiece,
          ));
        }
      }
    }

    // Castling
    moves.addAll(_getCastlingMoves(position));

    return moves;
  }

  List<ChessMove> _getCastlingMoves(Position kingPosition) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(kingPosition);

    if (piece == null || piece.type != PieceType.king || piece.hasMoved) {
      return moves;
    }

    final color = piece.color;
    final row = color == PieceColor.white ? 7 : 0;

    // King-side castling
    if ((color == PieceColor.white ? whiteKingSideCastle : blackKingSideCastle) &&
        board.pieceAt(Position(row, 5)) == null &&
        board.pieceAt(Position(row, 6)) == null &&
        board.pieceAt(Position(row, 7))?.type == PieceType.rook &&
        !_isPositionAttacked(Position(row, 4), color.opponent) &&
        !_isPositionAttacked(Position(row, 5), color.opponent) &&
        !_isPositionAttacked(Position(row, 6), color.opponent)) {
      
      moves.add(ChessMove(
        from: kingPosition,
        to: Position(row, 6), // King moves to g1/g8
      ));
    }

    // Queen-side castling
    if ((color == PieceColor.white ? whiteQueenSideCastle : blackQueenSideCastle) &&
        board.pieceAt(Position(row, 3)) == null &&
        board.pieceAt(Position(row, 2)) == null &&
        board.pieceAt(Position(row, 1)) == null && // For queen side, need to check b-file too
        board.pieceAt(Position(row, 0))?.type == PieceType.rook &&
        !_isPositionAttacked(Position(row, 4), color.opponent) &&
        !_isPositionAttacked(Position(row, 3), color.opponent) &&
        !_isPositionAttacked(Position(row, 2), color.opponent)) {
      
      moves.add(ChessMove(
        from: kingPosition,
        to: Position(row, 2), // King moves to c1/c8
      ));
    }

    return moves;
  }

  List<ChessMove> _getSlidingMoves(Position position, List<Position> directions) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;

    for (final direction in directions) {
      var current = position + direction;
      
      while (current.inBounds) {
        final targetPiece = board.pieceAt(current);
        
        if (targetPiece == null) {
          // Empty square, can move here
          moves.add(ChessMove(from: position, to: current));
        } else {
          if (targetPiece.color != piece.color) {
            // Can capture opponent's piece
            moves.add(ChessMove(from: position, to: current, capturedPiece: targetPiece));
          }
          // Stop in either case (hit own piece or captured opponent's piece)
          break;
        }
        
        current = current + direction;
      }
    }

    return moves;
  }

  // Make a move on the board
  void makeMove(ChessMove move) {
    // Update castling rights if king or rook moves
    final piece = board.pieceAt(move.from)!;
    
    if (piece.type == PieceType.king) {
      if (piece.color == PieceColor.white) {
        whiteKingSideCastle = false;
        whiteQueenSideCastle = false;
      } else {
        blackKingSideCastle = false;
        blackQueenSideCastle = false;
      }
    } else if (piece.type == PieceType.rook) {
      // If a rook moves, remove castling rights for that side
      if (move.from.row == 0 && move.from.col == 0) {
        blackQueenSideCastle = false;
      } else if (move.from.row == 0 && move.to.col == 7) {
        blackKingSideCastle = false;
      } else if (move.from.row == 7 && move.to.col == 0) {
        whiteQueenSideCastle = false;
      } else if (move.from.row == 7 && move.to.col == 7) {
        whiteKingSideCastle = false;
      }
    }

    // Handle special moves
    if (piece.type == PieceType.pawn && 
        (move.to.row == 0 || move.to.row == 7)) {
      // Pawn promotion - for now, promote to queen
      final promotedPiece = ChessPiece(PieceType.queen, piece.color, hasMoved: true);
      board.setPieceAt(move.to, promotedPiece);
      board.setPieceAt(move.from, null);
    } else if (piece.type == PieceType.pawn && 
               move.from.col != move.to.col && 
               board.pieceAt(move.to) == null) {
      // En passant capture
      final capturedPawnPos = Position(move.from.row, move.to.col);
      board.setPieceAt(capturedPawnPos, null);
      board.movePiece(move.from, move.to);
    } else {
      // Regular move
      board.movePiece(move.from, move.to);
    }

    // Handle castling
    if (piece.type == PieceType.king && (move.to.col - move.from.col).abs() == 2) {
      // Castling move - also move the rook
      if (move.to.col == 6) { // Kingside
        final rookFrom = Position(move.from.row, 7);
        final rookTo = Position(move.from.row, 5);
        board.movePiece(rookFrom, rookTo);
      } else if (move.to.col == 2) { // Queenside
        final rookFrom = Position(move.from.row, 0);
        final rookTo = Position(move.from.row, 3);
        board.movePiece(rookFrom, rookTo);
      }
    }

    // Set en passant target if a pawn moves two squares
    if (piece.type == PieceType.pawn && (move.to.row - move.from.row).abs() == 2) {
      enPassantTarget = Position((move.from.row + move.to.row) ~/ 2, move.from.col);
    } else {
      enPassantTarget = null;
    }

    // Update game state
    moveHistory.add(move);
    PieceColor previousPlayer = currentPlayer;
    currentPlayer = currentPlayer.opponent;
    timer.switchTurns(currentPlayer);
    
    // Check for checkmate or stalemate
    final opponentMoves = getAllPossibleMoves();
    if (opponentMoves.isEmpty) {
      if (_isKingInCheck(board, currentPlayer)) {
        gameOver = true;
        winner = previousPlayer; // The player who just moved wins
      } else {
        // Stalemate
        gameOver = true;
        winner = null;
      }
    }
  }

  // Check if the king is in check
  bool _isKingInCheck(ChessBoard board, PieceColor color) {
    // Find the king
    Position? kingPos;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.pieceAt(Position(row, col));
        if (piece?.type == PieceType.king && piece?.color == color) {
          kingPos = Position(row, col);
          break;
        }
      }
      if (kingPos != null) break;
    }

    if (kingPos == null) return false; // No king found (shouldn't happen in a valid game)

    // Check if any opponent piece can attack the king
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.pieceAt(Position(row, col));
        if (piece != null && piece.color != color) {
          final moves = _getPossibleMovesForPieceWithoutCheckValidation(board, Position(row, col));
          if (moves.any((move) => move.to == kingPos)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // Check if a position is attacked by the opponent
  bool _isPositionAttacked(Position position, PieceColor attackerColor) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.pieceAt(Position(row, col));
        if (piece != null && piece.color == attackerColor) {
          final moves = _getPossibleMovesForPieceWithoutCheckValidation(board, Position(row, col));
          if (moves.any((move) => move.to == position)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Get possible moves for a piece without validating if it puts own king in check
  List<ChessMove> _getPossibleMovesForPieceWithoutCheckValidation(ChessBoard board, Position position) {
    final piece = board.pieceAt(position);
    if (piece == null) return [];

    final moves = <ChessMove>[];
    
    switch (piece.type) {
      case PieceType.pawn:
        moves.addAll(_getPawnMovesWithoutValidation(board, position));
        break;
      case PieceType.rook:
        moves.addAll(_getRookMovesWithoutValidation(board, position));
        break;
      case PieceType.knight:
        moves.addAll(_getKnightMovesWithoutValidation(board, position));
        break;
      case PieceType.bishop:
        moves.addAll(_getBishopMovesWithoutValidation(board, position));
        break;
      case PieceType.queen:
        moves.addAll(_getQueenMovesWithoutValidation(board, position));
        break;
      case PieceType.king:
        moves.addAll(_getKingMovesWithoutValidation(board, position));
        break;
    }

    return moves;
  }

  // Helper methods without king check validation
  List<ChessMove> _getPawnMovesWithoutValidation(ChessBoard board, Position position) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;
    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    // Move forward one square
    final oneStep = Position(position.row + direction, position.col);
    if (oneStep.inBounds && board.pieceAt(oneStep) == null) {
      moves.add(ChessMove(from: position, to: oneStep));
      
      // Move forward two squares from starting position
      final twoStep = Position(position.row + 2 * direction, position.col);
      if (position.row == startRow && board.pieceAt(twoStep) == null) {
        moves.add(ChessMove(from: position, to: twoStep));
      }
    }

    // Captures
    for (int colOffset in [-1, 1]) {
      final capturePos = Position(position.row + direction, position.col + colOffset);
      if (capturePos.inBounds) {
        final targetPiece = board.pieceAt(capturePos);
        if (targetPiece != null && targetPiece.color != piece.color) {
          moves.add(ChessMove(from: position, to: capturePos, capturedPiece: targetPiece));
        }
      }
    }

    return moves;
  }

  List<ChessMove> _getRookMovesWithoutValidation(ChessBoard board, Position position) {
    return _getSlidingMovesWithoutValidation(board, position, [
      Position(-1, 0), Position(1, 0), Position(0, -1), Position(0, 1)
    ]);
  }

  List<ChessMove> _getBishopMovesWithoutValidation(ChessBoard board, Position position) {
    return _getSlidingMovesWithoutValidation(board, position, [
      Position(-1, -1), Position(-1, 1), Position(1, -1), Position(1, 1)
    ]);
  }

  List<ChessMove> _getQueenMovesWithoutValidation(ChessBoard board, Position position) {
    return _getSlidingMovesWithoutValidation(board, position, Position.slidingDirections);
  }

  List<ChessMove> _getKnightMovesWithoutValidation(ChessBoard board, Position position) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;

    for (final direction in Position.knightDirections) {
      final target = position + direction;
      if (target.inBounds) {
        final targetPiece = board.pieceAt(target);
        if (targetPiece == null || targetPiece.color != piece.color) {
          moves.add(ChessMove(
            from: position,
            to: target,
            capturedPiece: targetPiece,
          ));
        }
      }
    }

    return moves;
  }

  List<ChessMove> _getKingMovesWithoutValidation(ChessBoard board, Position position) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;

    for (final direction in Position.slidingDirections) {
      final target = position + direction;
      if (target.inBounds) {
        final targetPiece = board.pieceAt(target);
        if (targetPiece == null || targetPiece.color != piece.color) {
          moves.add(ChessMove(
            from: position,
            to: target,
            capturedPiece: targetPiece,
          ));
        }
      }
    }

    return moves;
  }

  List<ChessMove> _getSlidingMovesWithoutValidation(ChessBoard board, Position position, List<Position> directions) {
    final moves = <ChessMove>[];
    final piece = board.pieceAt(position)!;

    for (final direction in directions) {
      var current = position + direction;
      
      while (current.inBounds) {
        final targetPiece = board.pieceAt(current);
        
        if (targetPiece == null) {
          // Empty square, can move here
          moves.add(ChessMove(from: position, to: current));
        } else {
          if (targetPiece.color != piece.color) {
            // Can capture opponent's piece
            moves.add(ChessMove(from: position, to: current, capturedPiece: targetPiece));
          }
          // Stop in either case
          break;
        }
        
        current = current + direction;
      }
    }

    return moves;
  }

  // Helper to make a move on a board copy for validation
  ChessBoard _makeMoveOnBoard(ChessBoard originalBoard, ChessMove move) {
    final boardCopy = originalBoard.copy();
    
    // Apply the move to the copy
    final piece = boardCopy.pieceAt(move.from);
    if (piece != null) {
      boardCopy.setPieceAt(move.to, piece.copyWith(hasMoved: true));
      boardCopy.setPieceAt(move.from, null);
    }
    
    return boardCopy;
  }
}

// Extension to get opponent color
extension OpponentColor on PieceColor {
  PieceColor get opponent {
    return this == PieceColor.white ? PieceColor.black : PieceColor.white;
  }
}