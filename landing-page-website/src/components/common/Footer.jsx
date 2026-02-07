import { Component } from 'react';
import { Mail, Github, Twitter, Instagram } from 'lucide-react';

const Footer = () => {
  return (
    <footer className="relative bg-gradient-to-t from-[#0a0a0a] to-black text-white pt-24 pb-10 overflow-hidden border-t border-white/5">
      {/* Glow Effect */}
      <div className="absolute bottom-0 left-[20%] w-[60%] h-[300px] bg-radial-[at_50%_100%] from-primary/10 to-transparent pointer-events-none" />

      <div className="container mx-auto px-6 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-[1.5fr_1fr_1fr_1fr] gap-12 mb-20">

          {/* Brand */}
          <div className="footer-brand">
            <h2 className="text-3xl font-bold mb-6 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent inline-block">
              LVO App
            </h2>
            <p className="text-gray-400 mb-8 leading-relaxed max-w-sm">
              Platform sosial media karya anak bangsa. Berbagi momen, temukan inspirasi, dan terhubung dengan dunia dalam satu aplikasi.
            </p>
            <div className="flex gap-4">
              {[Twitter, Instagram, Github].map((Icon, i) => (
                <a key={i} href="#" className="h-10 w-10 flex items-center justify-center rounded-full bg-white/5 hover:bg-primary/20 hover:text-primary transition-all hover:-translate-y-1">
                  <Icon size={20} />
                </a>
              ))}
            </div>
          </div>

          {/* Links */}
          <div className="footer-links">
            <h4 className="mb-6 text-lg font-semibold tracking-wide uppercase">Navigasi</h4>
            <ul className="space-y-4">
              {['Beranda', 'Fitur', 'Tentang'].map((item) => (
                <li key={item}>
                  <a href={`#${item.toLowerCase() === 'beranda' ? 'home' : item.toLowerCase()}`} className="text-gray-400 hover:text-primary transition-colors hover:translate-x-1 inline-block">
                    {item}
                  </a>
                </li>
              ))}
              <li>
                <a href="https://play.google.com/store/apps/details?id=com.lvo.app" className="text-gray-400 hover:text-primary transition-colors hover:translate-x-1 inline-block">
                  Download
                </a>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div className="footer-links">
            <h4 className="mb-6 text-lg font-semibold tracking-wide uppercase">Legal</h4>
            <ul className="space-y-4">
              <li><a href="/privacy-policy" className="text-gray-400 hover:text-primary transition-colors">Kebijakan Privasi</a></li>
              <li><a href="#" className="text-gray-400 hover:text-primary transition-colors">Syarat & Ketentuan</a></li>
              <li><a href="#" className="text-gray-400 hover:text-primary transition-colors">Panduan Komunitas</a></li>
            </ul>
          </div>

          {/* Contact */}
          <div className="footer-contact">
            <h4 className="mb-6 text-lg font-semibold tracking-wide uppercase">Hubungi Kami</h4>
            <div className="flex items-center gap-3 text-gray-400 mb-4">
              <Mail className="text-primary" size={20} />
              <span>support@lvoapp.com</span>
            </div>
            <p className="text-gray-500 text-sm">
              Lampung, Indonesia
            </p>
          </div>
        </div>

        <div className="border-t border-white/5 pt-10 text-center text-gray-500 text-sm relative z-10">
          <p>&copy; {new Date().getFullYear()} LVO Dev. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
