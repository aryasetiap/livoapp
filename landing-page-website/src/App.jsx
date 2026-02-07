import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/layout/Layout';
import Home from './pages/Home';
import PrivacyPolicy from './pages/PrivacyPolicy';

import Terms from './pages/Terms';
import CommunityGuidelines from './pages/CommunityGuidelines';

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/privacy-policy" element={<PrivacyPolicy />} />
          <Route path="/terms" element={<Terms />} />
          <Route path="/community-guidelines" element={<CommunityGuidelines />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
