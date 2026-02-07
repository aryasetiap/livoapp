import { motion } from 'framer-motion';

const screenshots = [
  "/assets/img/screenshot-1.png",
  "/assets/img/screenshot-2.png",
  "/assets/img/screenshot-3.png",
  "/assets/img/screenshot-4.png",
];

const Screenshots = () => {
  return (
    <section className="py-24 bg-gradient-to-b from-black to-[#050505] relative overflow-hidden">
      {/* Divider */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-40 h-[1px] bg-gradient-to-r from-transparent via-primary/30 to-transparent" />

      <motion.div
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        className="container mx-auto px-6 mb-12 text-center"
      >
        <h2 className="text-3xl md:text-4xl font-bold mb-4">Tampilan Aplikasi</h2>
        <p className="text-gray-400">Antarmuka modern dan intuitif</p>
      </motion.div>

      <div className="container mx-auto">
        <div className="flex overflow-x-auto pb-8 -mx-6 px-6 md:mx-0 md:px-0 md:overflow-visible md:flex-wrap md:justify-center gap-6 md:gap-12 snap-x snap-mandatory no-scrollbar">
          {screenshots.map((src, index) => (
            <div key={index} className="flex-shrink-0 snap-center first:pl-6 last:pr-6 md:first:pl-0 md:last:pr-0">
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="relative group w-[260px] md:w-[280px] rounded-[36px] overflow-hidden border-4 border-gray-800 bg-black shadow-2xl hover:scale-105 hover:-translate-y-2 transition-transform duration-300 z-10 hover:z-20 hover:shadow-primary/20"
              >
                <img src={src} alt={`Screenshot ${index + 1}`} className="w-full h-auto object-cover" />
              </motion.div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Screenshots;
