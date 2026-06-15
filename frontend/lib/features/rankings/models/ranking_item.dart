import 'package:flutter/material.dart';
import 'package:cinemora/core/constants/colors.dart';

class RankingList {
  final String emoji;
  final String title;
  final String subtitle;
  final int count;
  final Color accent;
  final List<String> images;
  final List<RankingEntry> entries;

  const RankingList({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.accent,
    required this.images,
    required this.entries,
  });
}

class RankingEntry {
  final String title;
  final String year;
  final String type;
  final String rating;
  final String image;

  const RankingEntry({
    required this.title,
    required this.year,
    required this.type,
    required this.rating,
    required this.image,
  });
}

const kRankingLists = [
  RankingList(
    emoji: '❤️',
    title: 'All-Time Favorites',
    subtitle: 'The absolute best content I\'ve ever seen',
    count: 3,
    accent: WColors.accentRed,
    images: [
      'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ],
    entries: [
      RankingEntry(
        title: 'Oppenheimer',
        year: '2023',
        type: 'Movie',
        rating: '8.3',
        image: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'The Dark Knight',
        year: '2008',
        type: 'Movie',
        rating: '9.0',
        image: 'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Attack on Titan',
        year: '2013',
        type: 'Anime',
        rating: '9.1',
        image: 'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ),
    ],
  ),
  RankingList(
    emoji: '🚀',
    title: 'Best Sci-Fi',
    subtitle: 'Mind-expanding science fiction',
    count: 4,
    accent: WColors.chartPurple,
    images: [
      'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
    ],
    entries: [
      RankingEntry(
        title: 'Interstellar',
        year: '2014',
        type: 'Movie',
        rating: '8.7',
        image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Inception',
        year: '2010',
        type: 'Movie',
        rating: '8.8',
        image: 'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Dune: Part Two',
        year: '2024',
        type: 'Movie',
        rating: '8.7',
        image: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Blade Runner 2049',
        year: '2017',
        type: 'Movie',
        rating: '8.0',
        image: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=80',
      ),
    ],
  ),
  RankingList(
    emoji: '⛩️',
    title: 'Top Anime',
    subtitle: 'Essential anime that never miss',
    count: 4,
    accent: WColors.accentRedSoft,
    images: [
      'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
    ],
    entries: [
      RankingEntry(
        title: 'Attack on Titan',
        year: '2013',
        type: 'Anime',
        rating: '9.1',
        image: 'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ),
      RankingEntry(
        title: 'Fullmetal Alchemist',
        year: '2009',
        type: 'Anime',
        rating: '9.1',
        image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Frieren',
        year: '2023',
        type: 'Anime',
        rating: '9.1',
        image: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Death Note',
        year: '2006',
        type: 'Anime',
        rating: '9.0',
        image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
      ),
    ],
  ),
  RankingList(
    emoji: '🤯',
    title: 'Mind-Blowing',
    subtitle: 'Unforgettable finales and twists',
    count: 3,
    accent: WColors.accentPurple,
    images: [
      'https://images.unsplash.com/photo-1528360983277-13d401cdc186?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=80',
    ],
    entries: [
      RankingEntry(
        title: 'Shogun',
        year: '2024',
        type: 'Series',
        rating: '9.1',
        image: 'https://images.unsplash.com/photo-1528360983277-13d401cdc186?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Dark',
        year: '2017',
        type: 'Series',
        rating: '8.7',
        image: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Arrival',
        year: '2016',
        type: 'Movie',
        rating: '7.9',
        image: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=80',
      ),
    ],
  ),
  RankingList(
    emoji: '📺',
    title: 'Binge-Worthy',
    subtitle: 'Can\'t stop watching',
    count: 3,
    accent: WColors.success,
    images: [
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
    ],
    entries: [
      RankingEntry(
        title: 'Breaking Bad',
        year: '2008',
        type: 'Series',
        rating: '9.5',
        image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Succession',
        year: '2018',
        type: 'Series',
        rating: '8.9',
        image: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'True Detective',
        year: '2014',
        type: 'Series',
        rating: '9.0',
        image: 'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
      ),
    ],
  ),
  RankingList(
    emoji: '🖤',
    title: 'Dark & Intense',
    subtitle: 'Psychologically gripping stories',
    count: 3,
    accent: WColors.mutedSecondaryDeep,
    images: [
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
    ],
    entries: [
      RankingEntry(
        title: 'Mindhunter',
        year: '2017',
        type: 'Series',
        rating: '8.6',
        image: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Parasite',
        year: '2019',
        type: 'Movie',
        rating: '8.5',
        image: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
      ),
      RankingEntry(
        title: 'Prisoners',
        year: '2013',
        type: 'Movie',
        rating: '8.1',
        image: 'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
      ),
    ],
  ),
];
