import 'piece.dart';

class ChessTimer {
  int _whiteTime;
  int _blackTime; // Time in seconds
  bool _isRunning = false;
  DateTime? _lastStartTime;
  PieceColor _currentPlayer;

  ChessTimer(int initialTimeMinutes, this._currentPlayer) 
      : _whiteTime = initialTimeMinutes * 60, 
        _blackTime = initialTimeMinutes * 60;

  int get whiteTime => _whiteTime;
  int get blackTime => _blackTime;
  bool get isRunning => _isRunning;
  PieceColor get currentPlayer => _currentPlayer;
  set currentPlayer(PieceColor color) { 
    _currentPlayer = color; 
  }

  void startTimer() {
    _isRunning = true;
    _lastStartTime = DateTime.now();
  }

  void pauseTimer() {
    _isRunning = false;
    if (_lastStartTime != null) {
      Duration elapsed = DateTime.now().difference(_lastStartTime!);
      if (_currentPlayer == PieceColor.white) {
        _whiteTime -= elapsed.inSeconds;
        _whiteTime = _whiteTime < 0 ? 0 : _whiteTime;
      } else {
        _blackTime -= elapsed.inSeconds;
        _blackTime = _blackTime < 0 ? 0 : _blackTime;
      }
      _lastStartTime = null;
    }
  }

  void switchTurns(PieceColor nextPlayer) {
    pauseTimer();
    _currentPlayer = nextPlayer;
    startTimer();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String getWhiteTimeFormatted() => formatTime(_whiteTime);
  String getBlackTimeFormatted() => formatTime(_blackTime);

  void update() {
    if (_isRunning && _lastStartTime != null) {
      Duration elapsed = DateTime.now().difference(_lastStartTime!);
      int elapsedSeconds = elapsed.inSeconds;
      
      if (_currentPlayer == PieceColor.white) {
        int newTime = _whiteTime - elapsedSeconds;
        _whiteTime = newTime < 0 ? 0 : newTime;
      } else {
        int newTime = _blackTime - elapsedSeconds;
        _blackTime = newTime < 0 ? 0 : newTime;
      }
    }
  }

  bool isTimeUp(PieceColor color) {
    if (color == PieceColor.white) {
      return _whiteTime <= 0;
    } else {
      return _blackTime <= 0;
    }
  }
}