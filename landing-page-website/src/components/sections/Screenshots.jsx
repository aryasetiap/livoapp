import { motion } from 'framer-motion';

const screenshots = [
  "/assets/img/lvo_app_hero_mockup_1770376128637.png",
  "/assets/img/lvo_app_hero_mockup_1770376175875.png",
  "/assets/img/lvo_app_hero_mockup_1770376128637.png",
  "/assets/img/lvo_app_hero_mockup_1770376175875.png",
  // Reuse existing mockups for demo if actual screenshots serve same purpose
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

      <div className="flex overflow-x-auto pb-12 pt-4 px-6 md:px-20 gap-8 lg:gap-12 scrollbar-none snap-x snap-mandatory">
        {screenshots.map((src, index) => (
          <motion.div 
            key={index}
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: index * 0.1 }}
            className="flex-none snap-center w-[280px] h-[560px] rounded-[36px] overflow-hidden border-4 border-gray-800 bg-black shadow-2xl relative group hover:scale-105 hover:-translate-y-2 transition-transform duration-300 z-10 hover:z-20 hover:shadow-primary/20"
          >
            <img src={src} alt={`Screenshot ${index + 1}`} className="w-full h-full object-cover" />
          </motion.div>
        ))}
      </div>
    </section>
  );
};

export default Screenshots;
