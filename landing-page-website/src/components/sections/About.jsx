import { motion } from 'framer-motion';

const About = () => {
  return (
    <section id="tentang" className="py-24 bg-gradient-to-b from-black to-dark-surface relative">
      <div className="container mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center max-w-4xl mx-auto"
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-4">Tentang LVO App</h2>
          <p className="text-secondary font-medium mb-12 tracking-wide uppercase text-sm">Karya Anak Bangsa untuk Dunia</p>

          <div className="bg-white/5 border border-white/5 rounded-3xl p-8 md:p-12 backdrop-blur-sm shadow-xl">
            <p className="text-gray-300 text-lg md:text-xl leading-relaxed mb-8">
              LVO App hadir sebagai jawaban atas kebutuhan platform sosial media yang tidak hanya sekadar tempat berbagi, tetapi juga <strong className="text-primary">ruang aman untuk berekspresi</strong>. Dikembangkan oleh <strong className="text-white">LVO Dev</strong>, kami berkomitmen menghadirkan pengalaman pengguna yang mulus, ringan, dan tetap kaya fitur.
            </p>
            <p className="text-gray-300 text-lg md:text-xl leading-relaxed">
              Visi kami adalah menghubungkan masyarakat Indonesia dan dunia dalam satu ekosistem digital yang positif, mendukung kreativitas, dan <strong className="text-primary">menjunjung tinggi privasi pengguna</strong>.
            </p>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default About;
