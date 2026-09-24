import 'package:flutter/material.dart';

import '../core/palette.dart';
import '../core/phosphor.dart';


class Feature {
  const Feature(this.label, this.icon, this.swatch);

  final String label;
  final IconData icon;
  final Swatch swatch;
}

class OnboardingPage {
  const OnboardingPage({required this.title, required this.body, required this.features, required this.focus});

  final List<String> title;
  final List<String> body;
  final List<Feature> features;
  final Alignment focus;
}

const onboardingPages = [
  OnboardingPage(
    title: ['Personalized', 'Fitness for Your', 'Real Life'],
    body: ['Get custom routes, workouts and', 'wellness tips based on your location,', 'goals and fitness level.'],
    focus: Alignment.center,
    features: [
      Feature('Running\nRoutes', PhosphorFill.personSimpleRun, Swatch.run),
      Feature('Gyms', PhosphorFill.barbell, Swatch.gym),
      Feature('Parks', PhosphorFill.treeEvergreen, Swatch.park),
      Feature('Water\nStations', PhosphorFill.drop, Swatch.water),
      Feature('Yoga Spots', PhosphorFill.flowerLotus, Swatch.yoga),
    ],
  ),
  OnboardingPage(
    title: ['Routes That', 'Match Your', 'Every Pace'],
    body: ['Loops, trails and riverside paths', 'sized to your distance, your time', 'and the way you like to move.'],
    focus: Alignment(-0.6, 0.2),
    features: [
      Feature('Park\nLoops', PhosphorFill.infinity, Swatch.run),
      Feature('Trail Runs', PhosphorFill.mountains, Swatch.park),
      Feature('City Walks', PhosphorFill.personSimpleWalk, Swatch.water),
      Feature('Hill\nClimbs', PhosphorFill.trendUp, Swatch.sunrise),
      Feature('Night Safe', PhosphorFill.moonStars, Swatch.night),
    ],
  ),
  OnboardingPage(
    title: ['Track Every', 'Step Toward', 'Your Goal'],
    body: ['Daily goals, streaks and gentle', 'nudges that turn small moves into', 'habits that really last.'],
    focus: Alignment(0.2, -0.4),
    features: [
      Feature('Daily\nSteps', PhosphorFill.personSimpleWalk, Swatch.run),
      Feature('Heart Rate', PhosphorFill.heartbeat, Swatch.heart),
      Feature('Calories', PhosphorFill.fire, Swatch.sunrise),
      Feature('Active\nMinutes', PhosphorFill.timer, Swatch.water),
      Feature('Streaks', PhosphorFill.lightning, Swatch.gym),
    ],
  ),
  OnboardingPage(
    title: ['Feel Better,', 'One Journey', 'at a Time'],
    body: ['Rest spots, water fountains and', 'safe routes, so every outing ends', 'with you feeling great.'],
    focus: Alignment(-0.2, 0.6),
    features: [
      Feature('Rest\nAreas', PhosphorFill.park, Swatch.teal),
      Feature('Fountains', PhosphorFill.drop, Swatch.water),
      Feature('Safe\nRoutes', PhosphorFill.shieldCheck, Swatch.night),
      Feature('Scenic\nViews', PhosphorFill.mountains, Swatch.park),
      Feature('Mindful', PhosphorFill.flowerLotus, Swatch.yoga),
    ],
  ),
];
