import { Link } from 'react-router-dom';
import { ArrowLeft, Shield, Lock, Eye, Server, UserCheck } from 'lucide-react';

const PrivacyPolicy = () => {
  const sections = [
    {
      title: "1. Pendahuluan",
      icon: Shield,
      content: (
        <>
          <p className="mb-4">
            Selamat datang di LVO App ("kami", "kita", atau "milik kami"). Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, mengungkapkan, dan menjaga informasi Anda saat menggunakan aplikasi seluler LVO App.
          </p>
          <p>
            LVO App adalah aplikasi media sosial yang ditujukan untuk pengguna umum di Indonesia. Kami berkomitmen untuk mematuhi kebijakan Google Play Store dan peraturan perlindungan data yang berlaku di Indonesia.
          </p>
        </>
      )
    },
    {
      title: "2. Informasi Pribadi",
      icon: Eye,
      content: (
        <>
          <p className="mb-4 font-semibold text-white">a. Informasi yang Anda Berikan Secara Langsung</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li><strong>Informasi Akun:</strong> Saat mendaftar, kami mengumpulkan nama lengkap, alamat email, dan kredensial login (melalui Google Sign-In).</li>
            <li><strong>Profil Pengguna:</strong> Foto profil, username, dan biodata yang Anda tambahkan bersifat publik.</li>
            <li><strong>Konten Pengguna (UGC):</strong> Foto, video, dan komentar yang Anda unggah diproses dan disimpan untuk ditampilkan di layanan kami.</li>
          </ul>

          <p className="mb-4 font-semibold text-white">b. Informasi yang Dikumpulkan Secara Otomatis</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li><strong>Informasi Perangkat:</strong> Model HP, versi Android, ID perangkat, dan alamat IP untuk keamanan dan analitik.</li>
            <li><strong>Data Log:</strong> Laporan crash dan data kinerja aplikasi untuk perbaikan bug (melalui Firebase Crashlytics).</li>
          </ul>

          <p className="mb-4 font-semibold text-white">c. Perizinan Aplikasi (Android Permissions)</p>
          <ul className="list-disc pl-6 space-y-2 text-gray-400">
            <li><strong>Kamera & Mikrofon:</strong> Diperlukan HANYA saat Anda menggunakan fitur kamera untuk mengambil foto/video atau saat live streaming.</li>
            <li><strong>Penyimpanan (Read/Write External Storage):</strong> Diperlukan untuk memilih foto/video dari galeri Anda untuk diunggah.</li>
          </ul>
        </>
      )
    },
    {
      title: "3. Penggunaan & Pembagian Data",
      icon: UserCheck,
      content: (
        <>
          <p className="mb-4">
            Kami menggunakan data Anda hanya untuk menyediakan fungsi aplikasi sosial media. <strong className="text-primary">Kami TIDAK menjual data pribadi Anda kepada pihak ketiga.</strong>
          </p>
          <p className="mb-2">Kami membagikan data hanya kepada penyedia layanan terpercaya berikut untuk operasional aplikasi:</p>
          <ul className="list-disc pl-6 space-y-2 text-gray-400">
            <li><strong>Google Firebase:</strong> Untuk autentikasi pengguna, penyimpanan database, media (Cloud Storage), dan analitik.</li>
            <li><strong>Google Play Services:</strong> Untuk layanan inti Android.</li>
          </ul>
        </>
      )
    },
    {
      title: "4. Privasi Anak-Anak",
      icon: Shield,
      content: (
        <>
          <p className="mb-4 font-bold text-red-400">PENTING:</p>
          <p className="mb-4">
            Layanan kami <strong>TIDAK ditujukan untuk anak-anak di bawah usia 13 tahun</strong>. Kami tidak dengan sengaja mengumpulkan informasi pribadi dari anak-anak di bawah 13 tahun.
          </p>
          <p>
            Jika kami mengetahui bahwa kami telah mengumpulkan data dari anak di bawah 13 tahun tanpa verifikasi izin orang tua, kami akan segera menghapus informasi tersebut dari server kami. Jika Anda adalah orang tua/wali dan mengetahui anak Anda memberikan data kepada kami, silakan hubungi kami.
          </p>
        </>
      )
    },
    {
      title: "5. Keamanan Data",
      icon: Lock,
      content: (
        <>
          <p className="mb-4">
            Kami menerapkan enkripsi HTTPS/TLS untuk semua pengiriman data antara aplikasi dan server. Password pengguna tidak disimpan di server kami karena kami menggunakan Google Sign-In dan Firebase Auth.
          </p>
        </>
      )
    },
    {
      title: "6. Perubahan Kebijakan",
      icon: Server,
      content: (
        <>
          <p className="mb-4">
            Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan apa pun dengan memposting Kebijakan Privasi baru di halaman ini dan memperbarui "Tanggal Terakhir Diperbarui". Anda disarankan untuk meninjau halaman ini secara berkala.
          </p>
        </>
      )
    }
  ];

  return (
    <div className="min-h-screen pt-32 pb-20 container mx-auto px-6 max-w-5xl">
      {/* Header */}
      <div className="mb-12">
        <Link to="/" className="inline-flex items-center gap-2 text-gray-400 hover:text-primary transition-colors mb-8 group">
          <ArrowLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
          <span>Kembali ke Beranda</span>
        </Link>
        <h1 className="text-4xl md:text-6xl font-bold mb-4 bg-gradient-to-r from-white to-gray-500 bg-clip-text text-transparent">Kebijakan Privasi</h1>
        <p className="text-gray-400 text-lg">Terakhir diperbarui: {new Date().toLocaleDateString('id-ID', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
      </div>

      {/* Content */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-12">
        {/* Sidebar / Table of Contents (Desktop) */}
        <div className="hidden lg:block lg:col-span-4">
          <div className="sticky top-32 p-6 rounded-2xl bg-white/5 border border-white/5 backdrop-blur-sm">
            <h3 className="text-xl font-bold text-white mb-6">Daftar Isi</h3>
            <nav className="space-y-4">
              {sections.map((section, index) => (
                <a
                  key={index}
                  href={`#section-${index}`}
                  className="block text-gray-400 hover:text-primary transition-colors text-sm font-medium"
                >
                  {section.title}
                </a>
              ))}
            </nav>
            <div className="mt-8 pt-6 border-t border-white/10">
              <p className="text-sm text-gray-500 mb-2">Ada pertanyaan?</p>
              <a href="mailto:support@lvoapp.com" className="text-primary hover:text-white transition-colors font-semibold">
                support@lvoapp.com
              </a>
            </div>
          </div>
        </div>

        {/* Main Content */}
        <div className="lg:col-span-8 space-y-12">
          {sections.map((section, index) => {
            const Icon = section.icon;
            return (
              <section key={index} id={`section-${index}`} className="group">
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary group-hover:scale-110 transition-transform duration-300">
                    <Icon size={24} />
                  </div>
                  <h2 className="text-2xl font-bold text-white group-hover:text-primary transition-colors">{section.title}</h2>
                </div>
                <div className="bg-dark-surface p-8 rounded-3xl border border-white/5 leading-relaxed text-gray-300 shadow-lg group-hover:border-primary/20 transition-colors">
                  {section.content}
                </div>
              </section>
            );
          })}

          {/* Deletion Section */}
          <section className="bg-gradient-to-br from-red-500/10 to-red-900/10 p-8 rounded-3xl border border-red-500/20">
            <h2 className="text-2xl font-bold text-red-400 mb-4">Penghapusan Data</h2>
            <p className="text-gray-300 mb-4">
              Anda memiliki hak untuk meminta penghapusan akun dan data terkait kapan saja. Anda dapat melakukan ini melalui menu <strong>Pengaturan {'>'} Hapus Akun</strong> di dalam aplikasi, atau dengan menghubungi kami.
            </p>
            <p className="text-gray-400 text-sm">
              Kami akan memproses permintaan penghapusan data Anda dalam waktu 30 hari sesuai dengan ketentuan yang berlaku.
            </p>
          </section>
        </div>
      </div>
    </div>
  );
};

export default PrivacyPolicy;
