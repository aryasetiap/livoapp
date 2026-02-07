import Navbar from '../common/Navbar';
import Footer from '../common/Footer';

const Layout = ({ children }) => {
  return (
    <div className="min-h-screen bg-black text-white selection:bg-primary/30 selection:text-white">
      <Navbar />
      <main className="relative z-0">
        {children}
      </main>
      <Footer />
    </div>
  );
};

export default Layout;
