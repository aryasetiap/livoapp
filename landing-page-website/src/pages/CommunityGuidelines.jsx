import { Link } from 'react-router-dom';
import { ArrowLeft, Heart, ShieldAlert, UserX, MessageCircle, Copyright } from 'lucide-react';

const CommunityGuidelines = () => {
    const guidelines = [
        {
            title: "Saling Menghormati",
            icon: Heart,
            content: "Perlakukan orang lain sebagaimana Anda ingin diperlakukan. Kami tidak menoleransi pelecehan, intimidasi, atau ujaran kebencian."
        },
        {
            title: "Keamanan & Keselamatan",
            icon: ShieldAlert,
            content: "Dilarang memposting konten yang mempromosikan kekerasan, melukai diri sendiri, atau aktivitas ilegal yang berbahaya."
        },
        {
            title: "Konten Seksual & Telanjang",
            icon: UserX,
            content: "LVO App adalah platform untuk umum. Kami tidak mengizinkan konten pornografi atau seksual eksplisit."
        },
        {
            title: "Spam & Penipuan",
            icon: MessageCircle,
            content: "Jangan memposting spam, tautan menyesatkan, atau mencoba menipu pengguna lain untuk keuntungan finansial."
        },
        {
            title: "Hak Kekayaan Intelektual",
            icon: Copyright,
            content: "Hormati hak cipta orang lain. Jangan memposting konten yang bukan milik Anda tanpa izin atau atribusi yang sesuai."
        }
    ];

    return (
        <div className="min-h-screen pt-32 pb-20 container mx-auto px-6 max-w-4xl">
            <div className="mb-12 text-center">
                <Link to="/" className="inline-flex items-center gap-2 text-gray-400 hover:text-primary transition-colors mb-8 group">
                    <ArrowLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
                    <span>Kembali ke Beranda</span>
                </Link>
                <h1 className="text-4xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">Panduan Komunitas</h1>
                <p className="text-xl text-gray-400 max-w-2xl mx-auto">
                    Membangun komunitas yang positif, aman, dan inklusif adalah tanggung jawab kita bersama.
                </p>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                {guidelines.map((item, index) => {
                    const Icon = item.icon;
                    return (
                        <div key={index} className="bg-dark-surface p-8 rounded-3xl border border-white/5 hover:border-primary/20 transition-all hover:-translate-y-1">
                            <div className="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center text-primary mb-6">
                                <Icon size={24} />
                            </div>
                            <h3 className="text-xl font-bold text-white mb-3">{item.title}</h3>
                            <p className="text-gray-400 leading-relaxed">
                                {item.content}
                            </p>
                        </div>
                    );
                })}
            </div>

            <div className="mt-16 p-8 rounded-3xl bg-gradient-to-r from-primary/10 to-secondary/10 border border-primary/20 text-center">
                <h3 className="text-2xl font-bold text-white mb-4">Laporkan Pelanggaran</h3>
                <p className="text-gray-300 mb-6 max-w-2xl mx-auto">
                    Jika Anda melihat konten atau perilaku yang melanggar pedoman ini, harap segera laporkan melalui fitur pelaporan di dalam aplikasi atau hubungi tim dukungan kami.
                </p>
                <a href="mailto:support@lvoapp.com" className="inline-block px-8 py-3 bg-primary text-white rounded-full font-bold hover:bg-primary/80 transition-colors">
                    Hubungi Dukungan
                </a>
            </div>
        </div>
    );
};

export default CommunityGuidelines;
