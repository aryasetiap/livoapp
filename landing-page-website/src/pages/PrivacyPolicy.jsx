const PrivacyPolicy = () => {
  return (
    <div className="pt-32 pb-20 container mx-auto px-6 max-w-4xl">
      <div className="text-center mb-16">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">Privacy Policy</h1>
        <p className="text-gray-400">Last updated: {new Date().toLocaleDateString()}</p>
      </div>

      <div className="space-y-12 text-gray-300 leading-relaxed">
        <section className="bg-white/5 p-8 rounded-2xl border border-white/5">
          <h2 className="text-2xl font-bold text-white mb-4 pb-4 border-b border-white/10">1. Information Collection and Use</h2>
          <p className="mb-4">
            For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to:
          </p>
          <ul className="list-disc pl-6 space-y-2 mb-4">
            <li><strong>User Persona:</strong> Name, Email Address, User ID, Profile Picture.</li>
            <li><strong>Device Information:</strong> Model, OS version, IP address, Device Identifiers.</li>
            <li><strong>User Content:</strong> Photos, Videos, and Audio uploaded by you.</li>
          </ul>
          <p>
            The information that we request will be retained by us and used as described in this privacy policy. We use this information to provide features, authenticate users, and improve app stability.
          </p>
          <p className="mt-4">The app does use third party services that may collect information used to identify you:</p>
          <ul className="list-disc pl-6 space-y-2 mt-2 text-primary">
            <li><a href="https://www.google.com/policies/privacy/" target="_blank" rel="noreferrer" className="hover:underline">Google Play Services</a></li>
            <li><a href="https://firebase.google.com/policies/analytics" target="_blank" rel="noreferrer" className="hover:underline">Google Analytics for Firebase</a></li>
            <li><a href="https://firebase.google.com/support/privacy/" target="_blank" rel="noreferrer" className="hover:underline">Firebase Crashlytics</a></li>
            <li><a href="https://firebase.google.com/terms/auth" target="_blank" rel="noreferrer" className="hover:underline">Firebase Authentication</a></li>
          </ul>
        </section>

        <section className="bg-white/5 p-8 rounded-2xl border border-white/5">
          <h2 className="text-2xl font-bold text-white mb-4 pb-4 border-b border-white/10">2. Data Safety & Deletion</h2>
          <p className="mb-4"><strong>Data Retention:</strong> We retain your personal data only for as long as necessary to provide you with our services and for legitimate business purposes.</p>
          <p className="mb-4"><strong>Deletion Rights:</strong> You have the right to request the deletion of your account and associated data at any time. You can do this within the app settings under "Delete Account" or by contacting us at <a href="mailto:support@lvoapp.com" className="text-primary hover:underline">support@lvoapp.com</a>. Upon request, we will delete your data within 30 days.</p>
          <p><strong>Data Security:</strong> All data transmitted between the app and our servers is encrypted using TLS/SSL protocols.</p>
        </section>

        <section className="bg-white/5 p-8 rounded-2xl border border-white/5">
             <h2 className="text-2xl font-bold text-white mb-4 pb-4 border-b border-white/10">3. Log Data</h2>
             <p>
                We want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol ("IP") address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.
            </p>
        </section>

        <section className="bg-white/5 p-8 rounded-2xl border border-white/5">
            <h2 className="text-2xl font-bold text-white mb-4 pb-4 border-b border-white/10">4. Contact Us</h2>
            <p>
                If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at <a href="mailto:support@lvoapp.com" className="text-primary hover:underline">support@lvoapp.com</a>.
            </p>
        </section>
      </div>
    </div>
  );
};

export default PrivacyPolicy;
