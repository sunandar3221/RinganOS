import subprocess
import time
import os

def test_qemu():
    print("[*] Menjalankan QEMU untuk RinganOS...")
    
    # Jalankan QEMU dengan monitor via pipe
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
    
    # Tunggu 1.5 detik agar RinganOS selesai boot
    time.sleep(1.5)
    
    print("[*] Mengambil screenshot saat pertama kali boot...")
    proc.stdin.write("screendump ringanos_boot.ppm\n")
    proc.stdin.flush()
    time.sleep(0.5)
    
    # Fungsi untuk mengirim penekanan tombol
    def send_keys(text):
        for char in text:
            if char == ' ':
                proc.stdin.write("sendkey spc\n")
            elif char == '\n':
                proc.stdin.write("sendkey ret\n")
            elif char == '-':
                proc.stdin.write("sendkey minus\n")
            elif char == '!':
                proc.stdin.write("sendkey shift-1\n")
            elif char.isupper():
                proc.stdin.write(f"sendkey shift-{char.lower()}\n")
            else:
                proc.stdin.write(f"sendkey {char}\n")
            proc.stdin.flush()
            time.sleep(0.06)
        proc.stdin.write("sendkey ret\n")
        proc.stdin.flush()
        time.sleep(0.6)

    print("[*] Mengetik perintah 'time'...")
    send_keys("time")
    time.sleep(0.4)

    print("[*] Mengetik perintah 'date'...")
    send_keys("date")
    time.sleep(0.4)

    print("[*] Mengetik perintah 'about'...")
    send_keys("about")
    time.sleep(0.4)

    print("[*] Mengetik perintah 'echo Halo Dunia dari RinganOS!'...")
    send_keys("echo Halo Dunia dari RinganOS!")
    time.sleep(0.4)

    print("[*] Mengambil screenshot setelah perintah dijalankan...")
    proc.stdin.write("screendump ringanos_shell.ppm\n")
    proc.stdin.flush()
    time.sleep(0.8)

    # Tutup QEMU
    print("[*] Menghentikan QEMU...")
    proc.stdin.write("quit\n")
    proc.stdin.flush()
    proc.wait(timeout=5)

    # Konversi PPM ke PNG menggunakan ffmpeg
    for ppm in ["ringanos_boot.ppm", "ringanos_shell.ppm"]:
        if os.path.exists(ppm):
            png = ppm.replace(".ppm", ".png")
            print(f"[*] Mengonversi {ppm} ke {png}...")
            subprocess.run(["ffmpeg", "-y", "-i", ppm, png], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print(f"[+] Berhasil membuat {png}!")

if __name__ == "__main__":
    test_qemu()
