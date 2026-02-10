import { Link } from 'react-router-dom';
import { ArrowLeft, Shield, Lock, Eye, Server, UserCheck, Trash2 } from 'lucide-react';

const PrivacyPolicy = () => {
  const sections = [
    {
      title: "1. Pendahuluan",
      icon: Shield,
      content: (
        <>
          <p className="mb-4">
            Selamat datang di LVO App (“kami”, “kita”, atau “milik kami”). Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi pengguna saat Anda menggunakan aplikasi LVO App.
          </p>
          <p>
            LVO App adalah aplikasi media sosial yang ditujukan untuk pengguna umum di Indonesia dan dirancang sesuai dengan Kebijakan Developer Google Play serta peraturan perlindungan data yang berlaku.
          </p>
        </>
      )
    },
    {
      title: "2. Informasi yang Kami Kumpulkan",
      icon: Eye,
      content: (
        <>
          <p className="mb-4 font-semibold text-white">a. Informasi yang Anda Berikan Secara Langsung</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li><strong>Informasi Akun:</strong> Nama dan alamat email yang diperoleh melalui Google Sign-In, digunakan untuk autentikasi dan pengelolaan akun.</li>
            <li><strong>Profil Pengguna:</strong> Foto profil, username, dan biodata yang Anda tambahkan bersifat publik sesuai pengaturan aplikasi.</li>
            <li><strong>Konten Pengguna (User Generated Content):</strong> Foto, video, dan komentar yang Anda unggah, digunakan untuk menampilkan fitur media sosial di dalam aplikasi.</li>
          </ul>

          <p className="mb-4 font-semibold text-white">b. Informasi yang Dikumpulkan Secara Otomatis</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li><strong>Informasi Perangkat & Teknis:</strong> Model perangkat, versi sistem operasi Android, alamat IP, serta identifier non-personal (seperti Firebase Installation ID) yang digunakan untuk keamanan, pencegahan penyalahgunaan, dan analitik.</li>
            <li><strong>Data Log & Crash:</strong> Data kinerja aplikasi dan laporan error yang dikumpulkan melalui Firebase Crashlytics untuk peningkatan stabilitas dan perbaikan bug.</li>
          </ul>

          <p className="mb-4 font-semibold text-white">c. Perizinan Aplikasi (Android Permissions)</p>
          <ul className="list-disc pl-6 space-y-2 text-gray-400">
            <li><strong>Kamera & Mikrofon:</strong> Digunakan hanya saat Anda mengambil foto/video atau melakukan live streaming.</li>
            <li><strong>Penyimpanan:</strong> Digunakan untuk memilih dan mengunggah media dari galeri perangkat Anda.</li>
          </ul>
        </>
      )
    },
    {
      title: "3. Penggunaan & Pembagian Data",
      icon: UserCheck,
      content: (
        <>
          <p className="mb-4">Kami menggunakan data pengguna hanya untuk tujuan berikut:</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li>Menyediakan dan mengoperasikan fitur aplikasi</li>
            <li>Autentikasi dan keamanan akun</li>
            <li>Personalisasi pengalaman pengguna</li>
            <li>Analitik dan peningkatan kualitas layanan</li>
          </ul>
          <p className="mb-4">
            Kami tidak menjual data pribadi pengguna.
          </p>
          <p className="mb-2">Data hanya dibagikan kepada penyedia layanan pihak ketiga yang diperlukan untuk operasional aplikasi, antara lain:</p>
          <ul className="list-disc pl-6 space-y-2 text-gray-400">
            <li>Google Firebase (Authentication, Firestore/Database, Cloud Storage, Analytics, Crashlytics)</li>
            <li>Google Play Services</li>
          </ul>
        </>
      )
    },
    {
      title: "4. Privasi Anak-Anak",
      icon: Shield,
      content: (
        <>
          <p className="mb-4">
            LVO App tidak ditujukan untuk anak-anak di bawah usia 13 tahun dan tidak mengizinkan pembuatan akun oleh anak di bawah 13 tahun.
          </p>
          <p className="mb-4">
            Kami tidak dengan sengaja mengumpulkan informasi pribadi dari anak-anak di bawah usia tersebut. Jika kami mengetahui adanya data anak di bawah 13 tahun yang dikumpulkan tanpa persetujuan orang tua atau wali, kami akan segera menghapus data tersebut.
          </p>
          <p>
            Orang tua atau wali dapat menghubungi kami melalui email jika memiliki kekhawatiran terkait data anak.
          </p>
        </>
      )
    },
    {
      title: "5. Keamanan Data",
      icon: Lock,
      content: (
        <>
          <p className="mb-4">Kami menerapkan langkah-langkah keamanan teknis dan organisasi yang wajar, termasuk:</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li>Enkripsi data menggunakan HTTPS/TLS</li>
            <li>Autentikasi aman melalui Google Sign-In & Firebase Authentication</li>
          </ul>
          <p>
            Kami tidak menyimpan password pengguna secara langsung di server kami.
          </p>
        </>
      )
    },
    {
      title: "6. Penghapusan Akun & Data",
      icon: Trash2,
      content: (
        <>
          <p className="mb-2">Pengguna memiliki hak untuk menghapus akun dan data pribadi kapan saja dengan:</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li>Menu Pengaturan {'>'} Hapus Akun di dalam aplikasi, atau</li>
            <li>Menghubungi kami melalui email</li>
          </ul>
          <p>
            Permintaan penghapusan data akan diproses maksimal 30 hari sesuai ketentuan yang berlaku.
          </p>
        </>
      )
    },
    {
      title: "7. Perubahan Kebijakan",
      icon: Server,
      content: (
        <>
          <p className="mb-4">
            Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan akan diumumkan dengan memperbarui tanggal “Terakhir diperbarui” di halaman ini.
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
        <p className="text-gray-400 text-lg">Terakhir diperbarui: 10 Februari 2026</p>
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


        </div>
      </div>
    </div>
  );
};

export default PrivacyPolicy;
