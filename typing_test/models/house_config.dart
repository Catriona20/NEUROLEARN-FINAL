import 'package:flutter/material.dart';

class HouseConfig {
  final String id;
  final String name;
  final String icon;
  final String trait;
  final String quote;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String placeholder;

  const HouseConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.trait,
    required this.quote,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.placeholder,
  });

  static const List<HouseConfig> houses = [
    HouseConfig(
      id: 'gryffindor',
      name: 'Gryffindor',
      icon: '🦁',
      trait: 'Courage & Bravery',
      quote: '"It takes a great deal of bravery to stand up to our enemies, but just as much to stand up to our friends."',
      primaryColor: Color(0xFF740001),
      secondaryColor: Color(0xFF2C0A0A),
      accentColor: Color(0xFFD3A625),
      placeholder: 'Show your Gryffindor courage...',
    ),
    HouseConfig(
      id: 'hufflepuff',
      name: 'Hufflepuff',
      icon: '🦡',
      trait: 'Loyalty & Hard Work',
      quote: '"Where they are just and loyal, those patient Hufflepuffs are true and unafraid of toil."',
      primaryColor: Color(0xFFECB939),
      secondaryColor: Color(0xFF1F1A05),
      accentColor: Color(0xFF372E29),
      placeholder: 'Display your Hufflepuff loyalty...',
    ),
    HouseConfig(
      id: 'ravenclaw',
      name: 'Ravenclaw',
      icon: '🦅',
      trait: 'Wisdom & Wit',
      quote: '"Wit beyond measure is man\'s greatest treasure."',
      primaryColor: Color(0xFF0E1A40),
      secondaryColor: Color(0xFF050A1A),
      accentColor: Color(0xFF946B2D),
      placeholder: 'Channel your Ravenclaw wisdom...',
    ),
    HouseConfig(
      id: 'slytherin',
      name: 'Slytherin',
      icon: '🐍',
      trait: 'Ambition & Cunning',
      quote: '"Those cunning folk use any means to achieve their ends."',
      primaryColor: Color(0xFF1A472A),
      secondaryColor: Color(0xFF0A1A0F),
      accentColor: Color(0xFFAAA9AD),
      placeholder: 'Show your Slytherin ambition...',
    ),
  ];
}
