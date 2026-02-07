import { Link } from 'react-router-dom';
import { ArrowLeft, FileText, Shield, AlertCircle, Scale, PenTool } from 'lucide-react';

const Terms = () => {
    const sections = [
        {
            title: "1. Penerimaan Ketentuan",
            icon: FileText,
            content: (
                <>
                    <p className="mb-4">
                        Dengan mengunduh, mengakses, atau menggunakan LVO App ("Layanan"), Anda setuju untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak menyetujui bagian mana pun dari ketentuan ini, Anda tidak diperkenankan menggunakan Layanan kami.
                    </p>
                </>
            )
        },
        {
            title: "2. Akun Pengguna",
            icon: Shield,
            content: (
                <>
                    <p className="mb-4">
                        Untuk menggunakan fitur tertentu dari Layanan, Anda harus mendaftar akun. Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda, termasuk kata sandi, dan untuk semua aktivitas yang terjadi di bawah akun Anda.
                    </p>
                    <p className="mb-4">
                        Anda setuju untuk segera memberi tahu kami tentang penggunaan akun Anda yang tidak sah atau pelanggaran keamanan lainnya.
                    </p>
                </>
            )
        },
        {
            title: "3. Konten Pengguna",
            icon: PenTool,
            content: (
                <>
                    <p className="mb-4">
                        Layanan kami memungkinkan Anda untuk memposting, menautkan, menyimpan, membagikan, dan menyediakan informasi, teks, grafik, video, atau materi lainnya ("Konten"). Anda bertanggung jawab sepenuhnya atas Konten yang Anda posting di Layanan, termasuk legalitas, keandalan, dan kesesuaiannya.
                    </p>
                    <p className="mb-4">
                        Dengan memposting Konten di Layanan, Anda memberi kami hak dan lisensi untuk menggunakan, memodifikasi, mempertunjukkan secara publik, menampilkan secara publik, mereproduksi, dan mendistribusikan Konten tersebut pada dan melalui Layanan.
                    </p>
                </>
            )
        },
        {
            title: "4. Penghentian",
            icon: AlertCircle,
            content: (
                <>
                    <p className="mb-4">
                        Kami dapat menghentikan atau menangguhkan akun Anda dengan segera, tanpa pemberitahuan atau kewajiban sebelumnya, dengan alasan apa pun, termasuk namun tidak terbatas pada jika Anda melanggar Syarat dan Ketentuan ini.
                    </p>
                    <p className="mb-4">
                        Setelah penghentian, hak Anda untuk menggunakan Layanan akan segera berakhir.
                    </p>
                </>
            )
        },
        {
            title: "5. Batasan Tanggung Jawab",
            icon: Scale,
            content: (
                <>
                    <p className="mb-4">
                        Dalam keadaan apa pun, LVO App, maupun direktur, karyawan, mitra, agen, pemasok, atau afiliasinya, tidak akan bertanggung jawab atas kerusakan tidak langsung, insidental, khusus, konsekuensial, atau hukuman, termasuk namun tidak terbatas pada, hilangnya keuntungan, data, penggunaan, atau kerugian tidak berwujud lainnya.
                    </p>
                </>
            )
        }
    ];

    return (
        <div className="min-h-screen pt-32 pb-20 container mx-auto px-6 max-w-4xl">
            <div className="mb-12">
                <Link to="/" className="inline-flex items-center gap-2 text-gray-400 hover:text-primary transition-colors mb-8 group">
                    <ArrowLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
                    <span>Kembali ke Beranda</span>
                </Link>
                <h1 className="text-4xl md:text-5xl font-bold mb-4 bg-gradient-to-r from-white to-gray-500 bg-clip-text text-transparent">Syarat & Ketentuan</h1>
                <p className="text-gray-400">Terakhir diperbarui: {new Date().toLocaleDateString('id-ID', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
            </div>

            <div className="space-y-8">
                {sections.map((section, index) => {
                    const Icon = section.icon;
                    return (
                        <div key={index} className="bg-dark-surface p-8 rounded-3xl border border-white/5 hover:border-primary/20 transition-colors">
                            <div className="flex items-center gap-4 mb-4">
                                <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
                                    <Icon size={20} />
                                </div>
                                <h2 className="text-xl font-bold text-white">{section.title}</h2>
                            </div>
                            <div className="text-gray-300 leading-relaxed pl-[3.5rem]">
                                {section.content}
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

export default Terms;
