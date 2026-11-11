import 'package:flutter/material.dart';

/// Periodic table style logo with two diagonally adjacent tiles:
/// Top-left: [ 10 | Ne ]
/// Bottom-right: [ 12 | Xa ]
class NexaLogo extends StatelessWidget {
  final double tileSize;
  final Color borderColor;
  final Color textColor;
  final double borderWidth;

  const NexaLogo({
    super.key,
    this.tileSize = 58.0,
    this.borderColor = Colors.white,
    this.textColor = Colors.white,
    this.borderWidth = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = tileSize * 2.0 - borderWidth;
    final totalHeight = tileSize * 2.0 - borderWidth;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top-Left Tile: Ne (10)
          Positioned(
            left: 0,
            top: 0,
            child: _buildTile(
              symbol: 'Ne',
              number: '10',
            ),
          ),
          // Bottom-Right Tile: Xa (12)
          Positioned(
            left: tileSize - borderWidth,
            top: tileSize - borderWidth,
            child: _buildTile(
              symbol: 'Xa',
              number: '12',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String symbol,
    required String number,
  }) {
    return Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Stack(
        children: [
          // Atomic number in top-right corner
          Positioned(
            top: tileSize * 0.06,
            right: tileSize * 0.08,
            child: Text(
              number,
              style: TextStyle(
                color: textColor,
                fontSize: tileSize * 0.22,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ),
          // Element symbol in center
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: tileSize * 0.08),
              child: Text(
                symbol,
                style: TextStyle(
                  color: textColor,
                  fontSize: tileSize * 0.44,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
