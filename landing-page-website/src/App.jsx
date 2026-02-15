import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/layout/Layout';
import ScrollToTop from './components/common/ScrollToTop';
import Home from './pages/Home';
import PrivacyPolicy from './pages/PrivacyPolicy';
import Terms from './pages/Terms';
import CommunityGuidelines from './pages/CommunityGuidelines';
import DeleteAccount from './pages/DeleteAccount';

function App() {
  return (
    <Router>
      <ScrollToTop />
      <Layout>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/privacy-policy" element={<PrivacyPolicy />} />
          <Route path="/terms" element={<Terms />} />
          <Route path="/community-guidelines" element={<CommunityGuidelines />} />
          <Route path="/delete-account" element={<DeleteAccount />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
