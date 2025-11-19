
import 'package:flutter/material.dart';

// --- Color Palette ---
const Color primaryGreen = Color(0xFF3AB83C);
const Color secondaryBlue = Color(0xFF9CC9FF);
const Color warningRed = Color(0xFFFF4F4F);
const Color textBlack = Color(0xFF252424);
const Color lightGrey = Color(0xFFE1E1E1);
const Color white = Color(0xFFFFFFFF);
// Dark Theme Colors
const Color darkPrimary = Color(0xFF121212);
const Color darkSecondary = Color(0xFF1E1E1E);
const Color darkText = Color(0xFFE0E0E0);

// --- Gradients ---
const Color primaryGradientTop = Color(0xFF38D39F);
const Color primaryGradientBottom = Color(0xFF3AB83C);

const LinearGradient primaryGradient = LinearGradient(
  colors: [primaryGradientTop, primaryGradientBottom],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
