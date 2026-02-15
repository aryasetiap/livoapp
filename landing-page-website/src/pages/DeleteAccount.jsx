import React, { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, Mail, Trash2, Clock, Shield, AlertCircle } from 'lucide-react';

const DeleteAccount = () => {
    
    useEffect(() => {
        document.title = "Delete Account – LVO App";
        
        // Update meta description
        const metaDescription = document.querySelector('meta[name="description"]');
        if (metaDescription) {
            metaDescription.setAttribute('content', "Learn how to request account and data deletion for LVO App.");
        } else {
            const meta = document.createElement('meta');
            meta.name = "description";
            meta.content = "Learn how to request account and data deletion for LVO App.";
            document.head.appendChild(meta);
        }
    }, []);

    const sections = [
        {
            title: "Account Deletion Request",
            icon: Mail,
            content: (
                <>
                    <p className="mb-4">
                        Users can request the deletion of their account and associated data by following these steps:
                    </p>
                    <div className="bg-black/20 p-4 rounded-xl border border-white/5 mb-4">
                        <ol className="list-decimal pl-5 space-y-2 text-gray-300">
                            <li>Send an email to: <a href="mailto:support@lvoapp.com" className="text-primary hover:text-white transition-colors font-medium">support@lvoapp.com</a></li>
                            <li>Use the subject: <span className="text-white font-medium">"Delete My Account"</span></li>
                            <li>Include the email address registered in the LVO App account</li>
                        </ol>
                    </div>
                </>
            )
        },
        {
            title: "Data That Will Be Deleted",
            icon: Trash2,
            content: (
                <>
                    <p className="mb-4">
                        When a deletion request is approved, we will permanently delete:
                    </p>
                    <ul className="list-disc pl-5 space-y-2 text-gray-300">
                        <li>User profile information</li>
                        <li>Uploaded photos and videos</li>
                        <li>Comments, likes, and interactions</li>
                        <li>Authentication and account data</li>
                    </ul>
                </>
            )
        },
        {
            title: "Data Retention (If Applicable)",
            icon: Clock,
            content: (
                <p>
                    Some system logs may be temporarily retained for security, fraud prevention, and legal compliance purposes for a maximum of 30 days, after which they will be automatically deleted.
                </p>
            )
        },
        {
            title: "Processing Time",
            icon: AlertCircle,
            content: (
                <p>
                    Account deletion requests are typically processed within 3–7 business days after verification.
                </p>
            )
        },
        {
            title: "Contact",
            icon: Shield,
            content: (
                <>
                    <p className="mb-2">
                        If you need help regarding account deletion, please contact:
                    </p>
                    <a href="mailto:support@lvoapp.com" className="text-primary hover:text-white transition-colors font-bold text-lg">
                        support@lvoapp.com
                    </a>
                </>
            )
        }
    ];

    return (
        <div className="min-h-screen pt-32 pb-20 container mx-auto px-6 max-w-4xl">
             {/* Header */}
            <div className="mb-12">
                <Link to="/" className="inline-flex items-center gap-2 text-gray-400 hover:text-primary transition-colors mb-8 group">
                    <ArrowLeft size={20} className="group-hover:-translate-x-1 transition-transform" />
                    <span>Back to Home</span>
                </Link>
                <h1 className="text-4xl md:text-6xl font-bold mb-4 bg-gradient-to-r from-red-500 to-orange-500 bg-clip-text text-transparent">Delete Account – LVO App</h1>
                <p className="text-gray-400 text-lg">Detailed information on how to delete your account and data.</p>
            </div>

            {/* Content */}
            <div className="space-y-8">
                {sections.map((section, index) => {
                    const Icon = section.icon;
                    return (
                        <section key={index} className="bg-dark-surface p-8 rounded-3xl border border-white/5 hover:border-primary/20 transition-all hover:-translate-y-1">
                            <div className="flex items-start gap-4">
                                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary shrink-0">
                                    <Icon size={24} />
                                </div>
                                <div className="flex-1">
                                    <h2 className="text-2xl font-bold text-white mb-4">{section.title}</h2>
                                    <div className="text-gray-400 leading-relaxed">
                                        {section.content}
                                    </div>
                                </div>
                            </div>
                        </section>
                    );
                })}
            </div>
        </div>
    );
};

export default DeleteAccount;
