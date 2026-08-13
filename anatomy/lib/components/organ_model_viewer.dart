import 'dart:convert' show jsonEncode;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../data/organs_data.dart';

class OrganModelViewer extends StatefulWidget {
  const OrganModelViewer({
    super.key,
    required this.organ,
    this.height,
    this.width,
    this.compact = false,
  });

  final String organ;
  final double? height;
  final double? width;
  final bool compact;

  @override
  State<OrganModelViewer> createState() => _OrganModelViewerState();
}

class _OrganModelViewerState extends State<OrganModelViewer> {
  bool _isLoading = true;

  @override
  void didUpdateWidget(covariant OrganModelViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organ != widget.organ) {
      _isLoading = true;
    }
  }

  String _hex(Color color) {
    final rgb = (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '#$rgb';
  }

  String _buildHotspotCss() {
    final hotspots = organById(widget.organ).hotspots;
    final buffer = StringBuffer();
    for (final hotspot in hotspots) {
      final color = _hex(hotspot.color);
      buffer.writeln('''
        button[slot="hotspot-${hotspot.id}"] {
          position: relative;
          width: 18px;
          height: 18px;
          border: none;
          border-radius: 50%;
          background: $color;
          cursor: pointer;
          box-shadow: 0 0 0 3px rgba(255,255,255,0.9), 0 3px 8px rgba(0,0,0,0.22);
          animation: badge-pulse 2.4s ease-out infinite;
        }
        button[slot="hotspot-${hotspot.id}"]::after {
          content: '${hotspot.label}';
          position: absolute;
          top: 24px;
          left: 50%;
          transform: translateX(-50%);
          white-space: nowrap;
          font-family: 'WorkSans', sans-serif;
          font-size: 11px;
          font-weight: 600;
          color: #142428;
          background: rgba(251,252,251,0.96);
          padding: 4px 10px;
          border-radius: 10px;
          box-shadow: 0 2px 10px rgba(20,36,40,0.16);
          opacity: 0;
          pointer-events: none;
          transition: opacity 0.2s ease;
        }
        button[slot="hotspot-${hotspot.id}"]:hover::after,
        button[slot="hotspot-${hotspot.id}"]:focus::after {
          opacity: 1;
        }
      ''');
    }
    buffer.writeln('''
      @keyframes badge-pulse {
        0% { box-shadow: 0 0 0 0 rgba(255,255,255,0.85), 0 3px 8px rgba(0,0,0,0.22); }
        70% { box-shadow: 0 0 0 12px rgba(255,255,255,0), 0 3px 8px rgba(0,0,0,0.22); }
        100% { box-shadow: 0 0 0 0 rgba(255,255,255,0), 0 3px 8px rgba(0,0,0,0.22); }
      }
    ''');
    return buffer.toString();
  }

  String _buildHotspotHtml() {
    final hotspots = organById(widget.organ).hotspots;
    return hotspots
        .map(
          (h) =>
              '<button slot="hotspot-${h.id}" data-position="${h.x} ${h.y} ${h.z}" '
              'data-normal="0 0 1" aria-label="${h.label}"></button>',
        )
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? (widget.compact ? double.infinity : 320.w);
    final height = widget.height ?? 420.h;

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: SizedBox(
          key: ValueKey(widget.organ),
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ModelViewer(
                src: 'assets/models/${widget.organ}.glb',
                alt: '${widget.organ} 3D model',
                autoRotate: true,
                autoRotateDelay: 100,
                rotationPerSecond: '28deg',
                cameraControls: true,
                cameraTarget: 'auto',
                fieldOfView: 'auto',
                backgroundColor: Colors.transparent,
                loading: Loading.eager,
                reveal: Reveal.auto,
                innerModelViewerHtml: _buildHotspotHtml(),
                relatedCss: _buildHotspotCss(),
                debugLogging: false,
                javascriptChannels: {
                  JavascriptChannel(
                    'ModelLoaded',
                    onMessageReceived: (message) {
                      if (_isLoading && mounted) {
                        setState(() => _isLoading = false);
                      }
                    },
                  ),
                  JavascriptChannel(
                    'HotspotTapped',
                    onMessageReceived: (message) {
                      final data = jsonEncode(message.message);
                      debugPrint('Hotspot tapped: $data');
                    },
                  ),
                },
                relatedJs: '''
                  const viewer = document.querySelector('model-viewer');
                  viewer.addEventListener('load', () => {
                    if (window.ModelLoaded) {
                      ModelLoaded.postMessage('loaded');
                    }
                  });
                  viewer.addEventListener('error', () => {
                    if (window.ModelLoaded) {
                      ModelLoaded.postMessage('loaded');
                    }
                  });
                  viewer.querySelectorAll('button[slot^="hotspot-"]').forEach((btn) => {
                    btn.addEventListener('click', () => {
                      if (window.HotspotTapped) {
                        HotspotTapped.postMessage(btn.getAttribute('slot'));
                      }
                    });
                  });
                ''',
              ),
              if (_isLoading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36.w,
                        height: 36.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Loading specimen…',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
