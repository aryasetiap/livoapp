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
            Selamat datang di LVO App ("kami", "kita", atau "milik kami"). Kami berkomitmen untuk melindungi privasi dan keamanan data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, mengungkapkan, dan menjaga informasi Anda saat menggunakan aplikasi seluler dan situs web kami.
          </p>
          <p>
            Dengan menggunakan Layanan kami, Anda menyetujui pengumpulan dan penggunaan informasi sesuai dengan kebijakan ini. Jika Anda tidak setuju dengan ketentuan ini, mohon untuk tidak menggunakan aplikasi kami.
          </p>
        </>
      )
    },
    {
      title: "2. Informasi yang Kami Kumpulkan",
      icon: Eye,
      content: (
        <>
          <p className="mb-4 font-semibold text-white">a. Informasi yang Anda Berikan</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li><strong>Data Akun:</strong> Nama pengguna, alamat email, nomor telepon, foto profil, dan kredensial login.</li>
            <li><strong>Konten Pengguna (UGC):</strong> Foto, video, audio, komentar, dan pesan yang Anda unggah atau kirimkan melalui layanan.</li>
            <li><strong>Profil:</strong> Bio, minat, dan informasi lain yang Anda tambahkan ke profil publik Anda.</li>
          </ul>

          <p className="mb-4 font-semibold text-white">b. Informasi yang Dikumpulkan Secara Otomatis</p>
          <ul className="list-disc pl-6 space-y-2 mb-4 text-gray-400">
            <li><strong>Data Perangkat:</strong> Model perangkat, versi sistem operasi, ID perangkat unik, dan alamat IP.</li>
            <li><strong>Data Log:</strong> Waktu akses, durasi penggunaan, fitur yang dilihat, dan laporan crash.</li>
            <li><strong>Lokasi:</strong> (Opsional) Data lokasi umum atau tepat jika Anda mengizinkan akses lokasi untuk fitur tertentu.</li>
          </ul>

          <p className="mb-4 font-semibold text-white">c. Izin Perangkat</p>
          <p className="mb-2">Untuk memberikan fitur utama, kami mungkin meminta akses ke:</p>
          <ul className="list-disc pl-6 space-y-2 text-gray-400">
            <li><strong>Kamera & Mikrofon:</strong> Untuk mengambil foto, merekam video, dan fitur live streaming.</li>
            <li><strong>Penyimpanan/Galeri:</strong> Untuk mengunggah dan menyimpan konten media.</li>
          </ul>
        </>
      )
    },
    {
      title: "3. Penggunaan Informasi",
      icon: UserCheck,
      content: (
        <>
          <p className="mb-4">Kami menggunakan informasi yang dikumpulkan untuk:</p>
          <ul className="list-disc pl-6 space-y-2 text-gray-400">
            <li>Menyediakan, mengoperasikan, dan memelihara aplikasi LVO.</li>
            <li>Memproses unggahan konten dan interaksi sosial Anda.</li>
            <li>Meningkatkan pengalaman pengguna, personalisasi konten, dan analisis penggunaan.</li>
            <li>Mengelola akun Anda dan memberikan dukungan pelanggan.</li>
            <li>Mendeteksi dan mencegah aktivitas penipuan atau penyalahgunaan.</li>
          </ul>
        </>
      )
    },
    {
      title: "4. Keamanan Data",
      icon: Lock,
      content: (
        <>
          <p className="mb-4">
            Kami menerapkan langkah-langkah keamanan teknis dan organisasi yang sesuai untuk melindungi data pribadi Anda dari akses, penggunaan, atau pengungkapan yang tidak sah.
          </p>
          <p>
            Semua komunikasi data antara aplikasi dan server kami dienkripsi menggunakan protokol TLS/SSL standar industri. Namun, perlu diingat bahwa tidak ada metode transmisi melalui internet yang 100% aman.
          </p>
        </>
      )
    },
    {
      title: "5. Layanan Pihak Ketiga",
      icon: Server,
      content: (
        <>
          <p className="mb-4">Kami menggunakan layanan pihak ketiga terpercaya untuk operasional aplikasi:</p>
          <ul className="list-disc pl-6 space-y-2 text-primary">
            <li><a href="https://firebase.google.com/policies/analytics" target="_blank" rel="noreferrer" className="hover:underline hover:text-white transition-colors">Google Firebase (Auth, Analytics, Crashlytics)</a></li>
            <li><a href="https://policies.google.com/privacy" target="_blank" rel="noreferrer" className="hover:underline hover:text-white transition-colors">Google Play Services</a></li>
          </ul>
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
