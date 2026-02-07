import { useState, useEffect } from 'react';
import { Menu, X } from 'lucide-react';
import { Link } from 'react-router-dom';

const Navbar = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className={`fixed top-0 w-full z-50 transition-all duration-300 ${
      scrolled ? 'h-20 bg-black/85 shadow-lg backdrop-blur-md' : 'h-[90px] bg-black/60 backdrop-blur-md border-b border-white/10'
    }`}>
      <div className="container mx-auto px-6 h-full flex justify-between items-center">
        <Link to="/" className="flex items-center gap-4 text-2xl font-extrabold text-white tracking-tighter group">
          <img 
            src="/assets/img/lvo_logo_square.png" 
            alt="LVO Logo" 
            className="h-12 w-12 rounded-xl shadow-[0_0_20px_rgba(139,92,246,0.4)] transition-transform duration-300 group-hover:scale-110 group-hover:-rotate-3"
          />
          LVO App
        </Link>
        
        {/* Desktop Menu */}
        <nav className="hidden md:flex items-center gap-10">
          {['Beranda', 'Fitur', 'Tentang', 'Privasi'].map((item) => (
             <a 
               key={item}
               href={`#${item.toLowerCase() === 'beranda' ? 'home' : item.toLowerCase()}`} 
               className="font-semibold text-gray-400 hover:text-white relative group text-base"
             >
               {item}
               <span className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-primary to-secondary transition-all duration-300 group-hover:w-full"></span>
             </a>
          ))}
          <a href="https://play.google.com/store/apps/details?id=com.lvo.app" className="px-7 py-3 bg-primary text-white rounded-full font-bold shadow-[0_4px_15px_rgba(139,92,246,0.4)] hover:bg-primary-dark hover:-translate-y-0.5 hover:shadow-[0_8px_25px_rgba(139,92,246,0.5)] transition-all">
            Download App
          </a>
        </nav>

        {/* Mobile Menu Button */}
        <button 
          className="md:hidden text-white hover:text-primary transition-transform hover:scale-110"
          onClick={() => setIsOpen(!isOpen)}
        >
          {isOpen ? <X size={28} /> : <Menu size={28} />}
        </button>
      </div>

      {/* Mobile Menu Overlay */}
      <div className={`fixed inset-x-0 top-[90px] bg-black/95 backdrop-blur-xl border-b border-white/5 p-10 flex flex-col items-center gap-6 transition-transform duration-500 ease-in-out md:hidden ${
        isOpen ? 'translate-y-0 opacity-100' : '-translate-y-[150%] opacity-0'
      }`}>
        {['Beranda', 'Fitur', 'Tentang', 'Privasi'].map((item) => (
           <a 
             key={item}
             href={`#${item.toLowerCase() === 'beranda' ? 'home' : item.toLowerCase()}`}
             className="text-xl font-medium text-white hover:text-primary w-full text-center py-2 hover:bg-white/5 rounded-xl transition-colors"
             onClick={() => setIsOpen(false)}
           >
             {item}
           </a>
        ))}
        <a 
          href="https://play.google.com/store/apps/details?id=com.lvo.app" 
          className="w-full max-w-xs text-center py-3 bg-primary text-white rounded-full font-bold shadow-lg mt-4"
        >
          Download App
        </a>
      </div>
    </header>
  );
};

export default Navbar;
