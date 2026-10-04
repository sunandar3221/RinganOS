import subprocess
import time
import os

def test_gui():
    print("[*] Menjalankan QEMU untuk menguji RinganOS v2.0 GUI...")

    qemu_cmd = [
        "qemu-system-x86_64",
        "-drive", "format=raw,file=ringanos.img",
        "-display", "none",
        "-vga", "std",
        "-monitor", "stdio"
    ]

    proc = subprocess.Popen(
        qemu_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # 1. Boot up -> Tampilan Kalkulator
    time.sleep(1.5)
    print("[*] 1. Mengambil screenshot Kalkulator (Default)...")
    proc.stdin.write("screendump shot_calc.ppm\n")
    proc.stdin.flush()
    time.sleep(0.5)

    # 2. Tekan '2' -> Tampilan Catatan (Notepad)
    print("[*] 2. Membuka Catatan (Notepad)...")
    proc.stdin.write("sendkey 2\n")
    proc.stdin.flush()
    time.sleep(0.8)
    proc.stdin.write("screendump shot_note.ppm\n")
    proc.stdin.flush()
    time.sleep(0.5)

    # 3. Tekan '3' -> Tampilan Info Sistem
    print("[*] 3. Membuka Info Sistem...")
    proc.stdin.write("sendkey 3\n")
    proc.stdin.flush()
    time.sleep(0.8)
    proc.stdin.write("screendump shot_info.ppm\n")
    proc.stdin.flush()
    time.sleep(0.5)

    # 4. Tekan '4' -> Tampilan Mini Paint
    print("[*] 4. Membuka Mini Paint...")
    proc.stdin.write("sendkey 4\n")
    proc.stdin.flush()
    time.sleep(0.8)
    proc.stdin.write("screendump shot_paint.ppm\n")
    proc.stdin.flush()
    time.sleep(0.5)

    # 5. Tekan '0' -> Desktop Bersih (Hanya Ikon & Wallpaper)
    print("[*] 5. Menutup jendela untuk melihat Desktop...")
    proc.stdin.write("sendkey 0\n")
    proc.stdin.flush()
    time.sleep(0.8)
    proc.stdin.write("screendump shot_desktop.ppm\n")
    proc.stdin.flush()
    time.sleep(0.5)

    # Tutup QEMU
    print("[*] Selesai! Menghentikan QEMU...")
    proc.stdin.write("quit\n")
    proc.stdin.flush()
    proc.wait(timeout=5)

    # Konversi seluruh PPM ke PNG
    shots = [
        ("shot_calc.ppm", "ringanos_gui_calc.png"),
        ("shot_note.ppm", "ringanos_gui_note.png"),
        ("shot_info.ppm", "ringanos_gui_info.png"),
        ("shot_paint.ppm", "ringanos_gui_paint.png"),
        ("shot_desktop.ppm", "ringanos_gui_desktop.png")
    ]

    for ppm, png in shots:
        if os.path.exists(ppm):
            print(f"[*] Mengonversi {ppm} -> {png}...")
            subprocess.run(["ffmpeg", "-y", "-i", ppm, png], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            os.remove(ppm)
            print(f"[+] Berhasil: {png}")

if __name__ == "__main__":
    test_gui()
