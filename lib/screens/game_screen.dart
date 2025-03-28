import 'package:flutter/material.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  final String player1Symbol;
  final String player2Symbol;

  const GameScreen({
    Key? key,
    required this.player1Name,
    required this.player2Name,
    required this.player1Symbol,
    required this.player2Symbol,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<String>> _board;
  late bool _isPlayer1Turn;
  late String _gameStatus;
  late int _player1Score;
  late int _player2Score;
  bool _gameOver = false;
  List<List<int>>? _winningLine;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _board = List.generate(3, (_) => List.filled(3, ''));
    _isPlayer1Turn = true;
    _gameStatus = '${widget.player1Name}\'s turn';
    _player1Score = 0;
    _player2Score = 0;
    _gameOver = false;
    _winningLine = null;
  }

  void _makeMove(int row, int col) {
    if (_board[row][col].isNotEmpty || _gameOver) {
      return;
    }

    setState(() {
      _board[row][col] = _isPlayer1Turn ? widget.player1Symbol : widget.player2Symbol;
    });

    _checkGameStatus(row, col);

    if (!_gameOver) {
      _isPlayer1Turn = !_isPlayer1Turn;
      _gameStatus = '${_isPlayer1Turn ? widget.player1Name : widget.player2Name}\'s turn';
    }
  }

  void _checkGameStatus(int row, int col) {
    // Check row
    if (_board[row][0] == _board[row][1] &&
        _board[row][1] == _board[row][2] &&
        _board[row][0].isNotEmpty) {
      _endGame(_board[row][0], [[row, 0], [row, 1], [row, 2]]);
      return;
    }

    // Check column
    if (_board[0][col] == _board[1][col] &&
        _board[1][col] == _board[2][col] &&
        _board[0][col].isNotEmpty) {
      _endGame(_board[0][col], [[0, col], [1, col], [2, col]]);
      return;
    }

    // Check diagonals
    if (_board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2] &&
        _board[0][0].isNotEmpty) {
      _endGame(_board[0][0], [[0, 0], [1, 1], [2, 2]]);
      return;
    }

    if (_board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0] &&
        _board[0][2].isNotEmpty) {
      _endGame(_board[0][2], [[0, 2], [1, 1], [2, 0]]);
      return;
    }

    // Check for draw
    bool isDraw = true;
    for (var row in _board) {
      for (var cell in row) {
        if (cell.isEmpty) {
          isDraw = false;
          break;
        }
      }
    }

    if (isDraw) {
      setState(() {
        _gameStatus = 'Game Draw!';
        _gameOver = true;
      });

      Timer(const Duration(seconds: 2), () {
        _resetBoard();
      });
    }
  }

  void _endGame(String winner, List<List<int>> winningCells) {
    setState(() {
      if (winner == widget.player1Symbol) {
        _gameStatus = '${widget.player1Name} wins!';
        _player1Score++;
      } else {
        _gameStatus = '${widget.player2Name} wins!';
        _player2Score++;
      }
      _gameOver = true;
      _winningLine = winningCells;
    });

    Timer(const Duration(seconds: 2), () {
      _resetBoard();
    });
  }

  void _resetBoard() {
    setState(() {
      _board = List.generate(3, (_) => List.filled(3, ''));
      _isPlayer1Turn = true;
      _gameStatus = '${widget.player1Name}\'s turn';
      _gameOver = false;
      _winningLine = null;
    });
  }

  bool _isWinningCell(int row, int col) {
    if (_winningLine == null) return false;

    for (var cell in _winningLine!) {
      if (cell[0] == row && cell[1] == col) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.purple.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Score board
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPlayerScore(
                            widget.player1Name,
                            widget.player1Symbol,
                            _player1Score,
                            Colors.red.shade400,
                            _isPlayer1Turn && !_gameOver,
                          ),
                          const Text(
                            'vs',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          _buildPlayerScore(
                            widget.player2Name,
                            widget.player2Symbol,
                            _player2Score,
                            Colors.blue.shade400,
                            !_isPlayer1Turn && !_gameOver,
                          ),
                        ],
                      ),
                    ),

                    // Game status
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _gameStatus,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _gameOver
                              ? Colors.green
                              : _isPlayer1Turn
                              ? Colors.red.shade400
                              : Colors.blue.shade400,
                        ),
                      ),
                    ),

                    // Game board
                    Container(
                      margin: const EdgeInsets.all(20),
                      height: constraints.maxHeight * 0.5, // Use 50% of available height
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              final row = index ~/ 3;
                              final col = index % 3;
                              return GestureDetector(
                                onTap: () => _makeMove(row, col),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isWinningCell(row, col)
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _board[row][col],
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: _board[row][col] == widget.player1Symbol
                                            ? Colors.red.shade400
                                            : Colors.blue.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Reset button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _initializeGame();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Text(
                            'RESET GAME',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScore(
      String name,
      String symbol,
      int score,
      Color color,
      bool isActive,
      ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

