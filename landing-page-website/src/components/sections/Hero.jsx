import { motion } from 'framer-motion';

const Hero = () => {
  return (
    <section id="home" className="relative pt-40 pb-20 overflow-hidden">
      {/* Background Gradient */}
      <div className="absolute inset-0 bg-radial-[at_70%_20%] from-primary/10 to-transparent opacity-60" />

      <div className="container mx-auto px-6 relative z-10 grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">

        {/* Text Content */}
        <motion.div
          initial={{ opacity: 0, x: -50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
          className="max-w-2xl text-center lg:text-left mx-auto lg:mx-0"
        >
          <div className="inline-block px-4 py-2 rounded-full bg-white/5 border border-white/10 mb-6 backdrop-blur-sm">
            <span className="text-primary font-semibold text-sm tracking-wide uppercase">Sosial Media Indonesia</span>
          </div>
          <h1 className="text-5xl lg:text-7xl font-bold leading-[1.1] mb-6 tracking-tight">
            Ekspresikan Dirimu, <br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">
              Terhubung Tanpa Batas
            </span>
          </h1>
          <p className="text-xl text-gray-400 mb-10 leading-relaxed max-w-lg mx-auto lg:mx-0">
            Platform sosial media Indonesia yang mengutamakan kreativitas dan privasi. Temukan komunitasmu sekarang.
          </p>
          <div className="flex flex-wrap justify-center lg:justify-start gap-4">
            <a href="https://play.google.com/store/apps/details?id=com.lvo.app" className="px-8 py-4 bg-primary text-white rounded-full font-bold shadow-lg hover:shadow-primary/50 hover:-translate-y-1 transition-all flex items-center gap-3">
              <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Play Store" className="h-8" />
              <span>Download Gratis di Google Play</span>
            </a>
            <a href="#about" className="px-8 py-4 bg-white/5 text-white border border-white/10 rounded-full font-bold hover:bg-white/10 hover:-translate-y-1 transition-all">
              Pelajari Lebih Lanjut
            </a>
          </div>
        </motion.div>

        {/* Mockup */}
        <motion.div
          initial={{ opacity: 0, y: 50, rotate: 5 }}
          animate={{ opacity: 1, y: 0, rotate: 0 }}
          transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
          className="relative flex justify-center perspective-[1000px] perspective-origin-center transform-style-3d group"
        >
          {/* Glow behind phone */}
          <div className="absolute inset-0 bg-primary/20 blur-[100px] rounded-full transform translate-y-20 z-0" />

          <div className="mockup relative w-[300px] h-[600px] bg-dark-surface border-8 border-gray-800 rounded-[48px] shadow-[0_30px_60px_-15px_rgba(139,92,246,0.3)] overflow-hidden z-20 transform -rotate-y-12 rotate-x-6 transition-transform duration-500 ease-out group-hover:rotate-0">
            <img src="/assets/img/splash-screen.png" alt="App Mockup" className="w-full h-full object-cover opacity-90" />
          </div>
        </motion.div>

      </div>
    </section>
  );
};

export default Hero;
