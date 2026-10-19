"""Muxes rendered reel frames and the synthesized soundtrack into a social-ready MP4.

  python reel_mux.py <frames_dir> <audio.wav> <out.mp4>

H.264 High, yuv420p, 30 fps, 1080x1920, AAC 192k, loudness-normalized to -14 LUFS.
"""
import subprocess
import sys

import imageio_ffmpeg


def main(frames, audio, out):
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    cmd = [
        ffmpeg, '-y',
        '-framerate', '30', '-i', f'{frames}/f%04d.png',
        '-i', audio,
        '-c:v', 'libx264', '-preset', 'slow', '-crf', '16', '-pix_fmt', 'yuv420p',
        '-profile:v', 'high', '-level', '4.2', '-r', '30',
        '-af', 'loudnorm=I=-14:TP=-1.5:LRA=11',
        '-c:a', 'aac', '-b:a', '192k', '-ar', '48000',
        '-movflags', '+faststart', '-shortest',
        out,
    ]
    subprocess.run(cmd, check=True)


if __name__ == '__main__':
    main(*sys.argv[1:4])
