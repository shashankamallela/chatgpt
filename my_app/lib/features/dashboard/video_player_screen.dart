import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoPlayerScreen({
    super.key,
    required this.videoData,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  static const String fallbackEducationalVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  VideoPlayerController? videoController;
  ChewieController? chewieController;

  bool isLiked = false;
  bool isVideoLoading = false;
  bool isYoutubeVideo = false;
  String? videoError;

  @override
  void initState() {
    super.initState();
    initializeNetworkVideo();
  }

  Future<void> initializeNetworkVideo() async {
    final String fileUrl = _videoUrl();

    if (fileUrl.isEmpty) {
      setState(() {
        videoError = 'Video file is missing';
      });
      return;
    }

    if (_isYoutubeUrl(fileUrl)) {
      setState(() {
        isYoutubeVideo = true;
        isVideoLoading = false;
      });
      return;
    }

    setState(() {
      isYoutubeVideo = false;
      isVideoLoading = true;
    });

    try {
      final controller = await _createInitializedController(fileUrl);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      videoController = controller;
      chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
      );

      setState(() {
        isVideoLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isVideoLoading = false;
        videoError =
            'Unable to play this video. ${error.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  Future<VideoPlayerController> _createInitializedController(
    String fileUrl,
  ) async {
    try {
      return await _initializeController(fileUrl);
    } catch (_) {
      if (fileUrl == fallbackEducationalVideoUrl) {
        rethrow;
      }

      return _initializeController(fallbackEducationalVideoUrl);
    }
  }

  Future<VideoPlayerController> _initializeController(String fileUrl) async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(fileUrl),
      httpHeaders: const {
        'Accept': 'video/mp4,video/*;q=0.9,*/*;q=0.8',
      },
    );

    try {
      await controller.initialize();
      return controller;
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
  }

  String _videoUrl() {
    final String fileUrl = widget.videoData['file']?.toString() ?? '';

    if (fileUrl.isNotEmpty) {
      return fileUrl;
    }

    final String youtubeId = widget.videoData['youtubeId']?.toString() ?? '';
    if (youtubeId.isNotEmpty) {
      return fallbackEducationalVideoUrl;
    }

    return '';
  }

  bool _isYoutubeUrl(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase() ?? '';

    return host == 'youtu.be' ||
        host == 'www.youtube.com' ||
        host == 'youtube.com' ||
        host == 'm.youtube.com';
  }

  Future<void> _openVideoExternally() async {
    final uri = Uri.tryParse(_videoUrl());

    if (uri == null) {
      _showMessage('Video link is invalid');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage('Could not open this video');
      }
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    chewieController?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildScaffold(_buildNetworkPlayer());
  }

  Widget _buildNetworkPlayer() {
    if (isVideoLoading) {
      return const CircularProgressIndicator(
        color: Colors.white,
      );
    }

    final error = videoError;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    if (isYoutubeVideo) {
      return _buildYoutubeLauncher();
    }

    final chewie = chewieController;
    if (chewie == null) {
      return const Icon(
        Icons.play_circle_outline,
        color: Colors.white,
        size: 64,
      );
    }

    return Chewie(
      controller: chewie,
    );
  }

  Widget _buildYoutubeLauncher() {
    return InkWell(
      onTap: _openVideoExternally,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _openVideoExternally,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open YouTube'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffold(Widget player) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: player,
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.videoData['title'] ?? 'Untitled video',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _infoChip(
                        widget.videoData['duration'] ?? 'Video',
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _infoChip(
                        widget.videoData['category'] ?? 'Dental Care',
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isLiked
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isLiked ? "Liked" : "Like",
                                style: TextStyle(
                                  color: isLiked ? Colors.red : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _actionButton(
                        Icons.share_outlined,
                        "Share",
                        Colors.orange,
                      ),
                      _actionButton(
                        Icons.bookmark_border,
                        "Save",
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "About This Video",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.videoData['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6A11CB),
                          Color(0xFF2575FC),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Quick Tip",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.videoData['tip'] ??
                              "Brush your teeth for two minutes, twice a day.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
