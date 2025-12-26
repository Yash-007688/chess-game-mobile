import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chess_game.dart';
import '../models/chess_board.dart';
import '../models/piece.dart';
import '../models/timer.dart';
import '../models/computer_player.dart';
import '../models/chess_move.dart';
import '../widgets/chess_board_widget.dart';
import 'home_screen.dart'; // This will give access to GameMode

class GameScreen extends StatefulWidget {
  final GameMode gameMode;

  const GameScreen({super.key, required this.gameMode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ChessGame _game;
  Timer? _timer;
  ComputerPlayer? _computerPlayer;
  bool _isProcessingComputerMove = false;

  @override
  void initState() {
    super.initState();
    _game = ChessGame();
    
    if (widget.gameMode == GameMode.computer) {
      _computerPlayer = ComputerPlayer();
      // In computer mode, human plays white, computer plays black
      _game.currentPlayer = PieceColor.white; // Human starts
    }
    
    _game.timer.startTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _game.timer.update();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If in computer mode and it's the computer's turn, make the computer move
    if (widget.gameMode == GameMode.computer && 
        !_isProcessingComputerMove && 
        _game.currentPlayer == PieceColor.black && 
        !_game.gameOver) {
      _makeComputerMove();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513), // Saddle brown
        title: Text('Chess Game - ${widget.gameMode == GameMode.multiplayer ? 'Multiplayer' : 'vs Computer'}', 
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEDFCC), Color(0xFFDDB88C)],
          ),
        ),
        child: Column(
          children: [
            // Timer for black player (top)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _game.currentPlayer == PieceColor.black 
                          ? const Color(0xFF5DADE2).withOpacity(0.8) 
                          : const Color(0xFFA66D4F).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF654321),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.gameMode == GameMode.computer 
                          ? (_game.currentPlayer == PieceColor.black ? 'COMPUTER: ' : 'BLACK: ')
                          : 'BLACK: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _game.currentPlayer == PieceColor.black 
                            ? Colors.white 
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3D3D3).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF8B4513),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _game.timer.getBlackTimeFormatted(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF654321),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Game status bar
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF8B4513),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Current Player: ${_game.currentPlayer.name.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                  if (_game.gameOver)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _game.winner != null 
                          ? 'Game Over! ${_game.winner!.name.toUpperCase()} Wins!' 
                          : 'Game Over! Stalemate!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Chess board
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ChessBoardWidget(
                    game: _game,
                    boardSize: 350, // Slightly smaller for better mobile view
                    onMoveMade: _onMoveMade,
                  ),
                ),
              ),
            ),
            // Timer for white player (bottom)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _game.currentPlayer == PieceColor.white 
                          ? const Color(0xFF5DADE2).withOpacity(0.8) 
                          : const Color(0xFFA66D4F).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF8B4513),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.gameMode == GameMode.computer 
                          ? (_game.currentPlayer == PieceColor.white ? 'YOU: ' : 'WHITE: ')
                          : 'WHITE: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _game.currentPlayer == PieceColor.white 
                            ? Colors.white 
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3D3D3).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF8B4513),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _game.timer.getWhiteTimeFormatted(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF654321),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Game controls
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // New Game Button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _game.gameOver ? null : _resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('New Game', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  // Undo Button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E8B57), Color(0xFF228B22)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _game.moveHistory.isNotEmpty ? _undoMove : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Undo', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  // Home Button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B4513), Color(0xFF654321)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Home', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMoveMade() {
    // Called when a move is made by the UI
    if (widget.gameMode == GameMode.computer && 
        !_game.gameOver && 
        _game.currentPlayer == PieceColor.black) {
      // Schedule computer move after a short delay so the UI updates
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeComputerMove();
      });
    }
  }

  void _makeComputerMove() async {
    if (_game.gameOver || _game.currentPlayer != PieceColor.black || _isProcessingComputerMove) {
      return;
    }

    setState(() {
      _isProcessingComputerMove = true;
    });

    // Simulate computer "thinking" time
    await Future.delayed(const Duration(seconds: 1));

    if (_game.gameOver) {
      setState(() {
        _isProcessingComputerMove = false;
      });
      return;
    }

    ChessMove? computerMove = _computerPlayer?.getBestMoveWithBasicEvaluation(_game);
    
    if (computerMove != null) {
      _game.makeMove(computerMove);
    }

    setState(() {
      _isProcessingComputerMove = false;
    });
  }

  void _resetGame() {
    setState(() {
      _game.board = ChessBoard();
      if (widget.gameMode == GameMode.computer) {
        _game.currentPlayer = PieceColor.white; // Human starts
      } else {
        _game.currentPlayer = PieceColor.white; // Both players start with white in multiplayer
      }
      _game.gameOver = false;
      _game.winner = null;
      _game.moveHistory.clear();
      _game.whiteKingSideCastle = true;
      _game.whiteQueenSideCastle = true;
      _game.blackKingSideCastle = true;
      _game.blackQueenSideCastle = true;
      _game.enPassantTarget = null;
      _game.timer = ChessTimer(10, _game.currentPlayer);
      _game.timer.startTimer();
      _isProcessingComputerMove = false;
    });
  }

  void _undoMove() {
    if (_game.moveHistory.isEmpty) return;
    
    // For simplicity, we'll just reset the game
    // A more complex implementation would track game states
    _resetGame();
  }
}