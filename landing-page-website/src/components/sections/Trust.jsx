import { motion } from 'framer-motion';
import { ShieldCheck, Lock, UserCheck } from 'lucide-react';

const Trust = () => {
    const trustItems = [
        {
            icon: ShieldCheck,
            title: "Data Terenkripsi",
            description: "Keamanan Anda prioritas kami. Seluruh transmisi data dilindungi dengan enkripsi standar industri."
        },
        {
            icon: UserCheck,
            title: "Kendali Penuh",
            description: "Anda memegang kendali atas siapa yang dapat melihat profil dan konten yang Anda bagikan."
        },
        {
            icon: Lock,
            title: "Kebijakan Privasi Transparan",
            description: "Kami tidak menjual data pribadi Anda. Informasi hanya digunakan untuk meningkatkan pengalaman pengguna."
        }
    ];

    return (
        <section className="py-20 bg-dark-surface relative border-t border-white/5">
            <div className="container mx-auto px-6">
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    className="text-center mb-16"
                >
                    <div className="inline-block px-4 py-2 rounded-full bg-primary/10 border border-primary/20 mb-6">
                        <span className="text-primary font-semibold text-sm tracking-wide uppercase">Keamanan & Privasi</span>
                    </div>
                    <h2 className="text-3xl md:text-4xl font-bold mb-4">Komitmen Kami pada Privasi Anda</h2>
                    <p className="text-gray-400 max-w-2xl mx-auto">
                        LVO App dibangun dengan fondasi keamanan yang kuat untuk memastikan pengalaman bersosial media yang aman dan nyaman.
                    </p>
                </motion.div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    {trustItems.map((item, index) => {
                        const Icon = item.icon;
                        return (
                            <motion.div
                                key={index}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ duration: 0.5, delay: index * 0.1 }}
                                className="text-center p-6 rounded-3xl bg-black/40 border border-white/5"
                            >
                                <div className="w-16 h-16 mx-auto rounded-2xl bg-white/5 flex items-center justify-center mb-6 text-primary">
                                    <Icon size={32} />
                                </div>
                                <h3 className="text-xl font-bold mb-3 text-white">{item.title}</h3>
                                <p className="text-gray-400 text-sm leading-relaxed">{item.description}</p>
                            </motion.div>
                        );
                    })}
                </div>
            </div>
        </section>
    );
};

export default Trust;
