import { motion } from 'framer-motion';
import { Camera, Share2, Shield, Globe, Zap, Heart } from 'lucide-react';

const features = [
  {
    icon: Camera,
    title: "Kualitas HD",
    description: "Upload dan bagikan foto serta video dengan kualitas terbaik tanpa kompresi berlebih."
  },
  {
    icon: Share2,
    title: "Berbagi Instan",
    description: "Bagikan momen berharga ke berbagai platform lain hanya dengan satu sentuhan."
  },
  {
    icon: Shield,
    title: "Privasi Terjamin",
    description: "Data Anda aman bersama kami. Kontrol penuh atas siapa yang bisa melihat konten Anda."
  },
  {
    icon: Globe,
    title: "Komunitas Global",
    description: "Temukan teman baru dari seluruh dunia dan pelajari budaya baru."
  },
  {
    icon: Zap,
    title: "Ringan & Cepat",
    description: "Aplikasi dioptimalkan untuk berjalan lancar di berbagai perangkat Android."
  },
  {
    icon: Heart,
    title: "Bebas Iklan Mengganggu",
    description: "Nikmati pengalaman scrolling yang nyaman tanpa gangguan iklan yang berlebihan."
  }
];

const Features = () => {
  return (
    <section id="fitur" className="py-20 bg-black relative">
      <div className="container mx-auto px-6 relative z-10">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-4 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent inline-block">Fitur Unggulan</h2>
          <p className="text-gray-400 max-w-2xl mx-auto">
            Nikmati berbagai fitur canggih yang dirancang untuk memaksimalkan pengalaman sosial media Anda.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="group p-8 rounded-3xl bg-dark-surface border border-white/5 hover:border-primary/30 hover:bg-[#262f3d] transition-all duration-300 hover:-translate-y-3 hover:shadow-[0_20px_40px_-10px_rgba(0,0,0,0.4)]"
              >
                <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-primary/10 to-secondary/10 flex items-center justify-center mb-6 text-primary group-hover:scale-110 group-hover:rotate-6 transition-transform duration-300">
                  <Icon size={32} />
                </div>
                <h3 className="text-xl font-bold mb-3 text-white group-hover:text-primary transition-colors">{feature.title}</h3>
                <p className="text-gray-400 leading-relaxed text-sm">{feature.description}</p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
};

export default Features;
