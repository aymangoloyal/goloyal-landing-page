import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useToast } from "@/hooks/use-toast";
import { apiRequest } from "@/lib/queryClient";
import { default as goLoyalLogoDark, default as goLoyalLogoLight } from "@assets/go_loyal_logo.svg";
import { zodResolver } from "@hookform/resolvers/zod";
import { insertDemoRequestSchema, type InsertDemoRequest } from "@shared/schema";
import { useMutation } from "@tanstack/react-query";
import {
  BarChart3,
  CheckCircle,
  CreditCard,
  Menu,
  Settings,
  Shield,
  Smartphone,
  Star,
  Target,
  Users,
  X,
  Zap
} from "lucide-react";
import React, { useState } from "react";
import { useForm } from "react-hook-form";

export default function Home() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const { toast } = useToast();

  // Check for dark mode on component mount and when system theme changes
  React.useEffect(() => {
    const checkDarkMode = () => {
      const isDark = document.documentElement.classList.contains('dark') ||
        window.matchMedia('(prefers-color-scheme: dark)').matches;
      setIsDarkMode(isDark);
    };

    checkDarkMode();

    // Listen for theme changes
    const observer = new MutationObserver(checkDarkMode);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });

    // Listen for system theme changes
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQuery.addEventListener('change', checkDarkMode);

    return () => {
      observer.disconnect();
      mediaQuery.removeEventListener('change', checkDarkMode);
    };
  }, []);

  const form = useForm<InsertDemoRequest>({
    resolver: zodResolver(insertDemoRequestSchema),
    defaultValues: {
      businessName: "",
      contactName: "",
      email: "",
      phone: "",
    },
  });

  const demoRequestMutation = useMutation({
    mutationFn: async (data: InsertDemoRequest) => {
      const response = await apiRequest("POST", "/api/demo-requests", data);
      return response.json();
    },
    onSuccess: () => {
      toast({
        title: "Demo Request Submitted!",
        description: "We'll contact you within 24 hours to schedule your personalized demo.",
      });
      form.reset();
    },
    onError: (error) => {
      toast({
        title: "Error",
        description: "Failed to submit demo request. Please try again.",
        variant: "destructive",
      });
      console.error("Demo request error:", error);
    },
  });

  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: "smooth" });
    }
    setMobileMenuOpen(false);
  };

  const onSubmit = (data: InsertDemoRequest) => {
    demoRequestMutation.mutate(data);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Navigation */}
      <nav className="fixed w-full top-0 z-50 bg-white/95 backdrop-blur-sm border-b border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-4">
              <img
                src={isDarkMode ? goLoyalLogoDark : goLoyalLogoLight}
                alt="GoLoyal Logo"
                className="h-8 w-auto"
              />
              <span className="text-xl font-bold bg-gradient-to-r from-primary-blue to-primary-cyan bg-clip-text text-transparent">
                GoLoyal
              </span>
            </div>

            <div className="hidden md:flex items-center space-x-8">
              <button
                onClick={() => scrollToSection("features")}
                className="text-gray-600 hover:text-primary-blue transition-colors"
                data-testid="nav-features"
              >
                Features
              </button>
              <button
                onClick={() => scrollToSection("how-it-works")}
                className="text-gray-600 hover:text-primary-blue transition-colors"
                data-testid="nav-how-it-works"
              >
                How it Works
              </button>
              <button
                onClick={() => scrollToSection("integrations")}
                className="text-gray-600 hover:text-primary-blue transition-colors"
                data-testid="nav-integrations"
              >
                Integrations
              </button>
              <button
                onClick={() => scrollToSection("testimonials")}
                className="text-gray-600 hover:text-primary-blue transition-colors"
                data-testid="nav-testimonials"
              >
                Testimonials
              </button>
            </div>

            <div className="hidden md:flex items-center space-x-4">
              <Button variant="ghost" data-testid="button-sign-in">Sign In</Button>
              <Button
                className="bg-gradient-to-r from-primary-blue to-primary-cyan hover:shadow-lg transition-all duration-200 transform hover:scale-105"
                onClick={() => scrollToSection("cta")}
                data-testid="button-get-started"
              >
                Get Started
              </Button>
            </div>

            <button
              className="md:hidden"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              data-testid="button-mobile-menu"
            >
              {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>

          {mobileMenuOpen && (
            <div className="md:hidden py-4 space-y-2">
              <button
                onClick={() => scrollToSection("features")}
                className="block w-full text-left px-4 py-2 text-gray-600 hover:text-primary-blue"
                data-testid="mobile-nav-features"
              >
                Features
              </button>
              <button
                onClick={() => scrollToSection("how-it-works")}
                className="block w-full text-left px-4 py-2 text-gray-600 hover:text-primary-blue"
                data-testid="mobile-nav-how-it-works"
              >
                How it Works
              </button>
              <button
                onClick={() => scrollToSection("integrations")}
                className="block w-full text-left px-4 py-2 text-gray-600 hover:text-primary-blue"
                data-testid="mobile-nav-integrations"
              >
                Integrations
              </button>
              <button
                onClick={() => scrollToSection("testimonials")}
                className="block w-full text-left px-4 py-2 text-gray-600 hover:text-primary-blue"
                data-testid="mobile-nav-testimonials"
              >
                Testimonials
              </button>
            </div>
          )}
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-24 pb-16 bg-gradient-to-br from-light-gray via-white to-blue-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div className="text-center lg:text-left">
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-dark-navy mb-6 leading-tight">
                Transform Your Business with{" "}
                <span className="bg-gradient-to-r from-primary-blue to-primary-cyan bg-clip-text text-transparent">
                  Digital Loyalty
                </span>
              </h1>
              <p className="text-xl text-gray-600 mb-8 leading-relaxed">
                Launch professional loyalty programs and digital coupons that integrate seamlessly with Apple Wallet and Google Wallet. Perfect for local businesses ready to grow.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                <Button
                  size="lg"
                  className="bg-gradient-to-r from-primary-blue to-primary-cyan hover:shadow-xl transition-all duration-300 transform hover:scale-105 text-lg px-8 py-4"
                  onClick={() => scrollToSection("cta")}
                  data-testid="button-start-trial"
                >
                  Start Free Trial
                </Button>
                <Button
                  size="lg"
                  variant="outline"
                  className="border-2 border-primary-blue text-primary-blue hover:bg-primary-blue hover:text-white transition-all duration-300 text-lg px-8 py-4"
                  data-testid="button-watch-demo"
                >
                  Watch Demo
                </Button>
              </div>
              <div className="mt-8 flex items-center justify-center lg:justify-start space-x-6 text-sm text-gray-500">
                <div className="flex items-center">
                  <CheckCircle className="w-5 h-5 text-green-500 mr-2" />
                  <span>No Setup Fees</span>
                </div>
                <div className="flex items-center">
                  <CheckCircle className="w-5 h-5 text-green-500 mr-2" />
                  <span>14-Day Free Trial</span>
                </div>
                <div className="flex items-center">
                  <CheckCircle className="w-5 h-5 text-green-500 mr-2" />
                  <span>Cancel Anytime</span>
                </div>
              </div>
            </div>

            <div className="relative">
              <Card className="shadow-2xl">
                <CardContent className="p-6">
                  <div className="bg-gradient-to-r from-primary-blue to-primary-cyan h-2 rounded-t-lg mb-4"></div>
                  <div className="space-y-4">
                    <div className="flex items-center space-x-3">
                      <div className="w-12 h-12 bg-gradient-to-r from-primary-blue to-primary-cyan rounded-lg flex items-center justify-center">
                        <CreditCard className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-gray-900">Coffee Shop Loyalty</h3>
                        <p className="text-sm text-gray-500">Active Program</p>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-green-50 p-4 rounded-lg">
                        <p className="text-2xl font-bold text-green-600">1,247</p>
                        <p className="text-sm text-green-600">Active Users</p>
                      </div>
                      <div className="bg-blue-50 p-4 rounded-lg">
                        <p className="text-2xl font-bold text-blue-600">89%</p>
                        <p className="text-sm text-blue-600">Redemption Rate</p>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Floating wallet cards */}
              <div className="absolute -top-4 -right-4 bg-white rounded-xl shadow-lg p-4 transform rotate-12">
                <div className="flex items-center space-x-2">
                  <div className="w-8 h-8 bg-gradient-to-r from-primary-blue to-primary-cyan rounded"></div>
                  <span className="text-sm font-medium">Apple Wallet</span>
                </div>
              </div>

              <div className="absolute -bottom-4 -left-4 bg-white rounded-xl shadow-lg p-4 transform -rotate-6">
                <div className="flex items-center space-x-2">
                  <div className="w-8 h-8 bg-gradient-to-r from-green-400 to-blue-500 rounded"></div>
                  <span className="text-sm font-medium">Google Wallet</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-dark-navy mb-4">
              Launch Your Loyalty Program in{" "}
              <span className="bg-gradient-to-r from-primary-blue to-primary-cyan bg-clip-text text-transparent">
                3 Simple Steps
              </span>
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Get your digital loyalty program up and running in minutes, not months. No technical expertise required.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center group">
              <div className="bg-gradient-to-r from-primary-blue to-primary-cyan w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                <Settings className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-dark-navy mb-4">Design Your Program</h3>
              <p className="text-gray-600 leading-relaxed">
                Choose from customizable templates or create your own loyalty program design. Set rewards, point values, and redemption rules that work for your business.
              </p>
            </div>

            <div className="text-center group">
              <div className="bg-gradient-to-r from-primary-cyan to-accent-cyan w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                <Smartphone className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-dark-navy mb-4">Distribute to Customers</h3>
              <p className="text-gray-600 leading-relaxed">
                Share QR codes, email links, or SMS invitations. Customers add your loyalty cards directly to their Apple Wallet or Google Wallet with one tap.
              </p>
            </div>

            <div className="text-center group">
              <div className="bg-gradient-to-r from-accent-cyan to-primary-blue w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                <BarChart3 className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-dark-navy mb-4">Track & Optimize</h3>
              <p className="text-gray-600 leading-relaxed">
                Monitor program performance with real-time analytics. See customer engagement, redemption rates, and revenue impact to optimize your strategy.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-gradient-to-br from-light-gray to-blue-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-dark-navy mb-4">
              Everything You Need to{" "}
              <span className="bg-gradient-to-r from-primary-blue to-primary-cyan bg-clip-text text-transparent">
                Drive Customer Loyalty
              </span>
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Powerful features designed specifically for local businesses to create engaging customer experiences.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <Card className="hover:shadow-xl transition-shadow duration-300 group">
              <CardContent className="p-8">
                <div className="bg-gradient-to-r from-primary-blue to-primary-cyan w-12 h-12 rounded-lg flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                  <CreditCard className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-dark-navy mb-4">Digital Loyalty Cards</h3>
                <p className="text-gray-600 leading-relaxed">
                  Create beautiful, branded loyalty cards that customers can store in their mobile wallets. No more lost plastic cards or forgotten punch cards.
                </p>
              </CardContent>
            </Card>

            <Card className="hover:shadow-xl transition-shadow duration-300 group">
              <CardContent className="p-8">
                <div className="bg-gradient-to-r from-primary-cyan to-accent-cyan w-12 h-12 rounded-lg flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                  <Target className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-dark-navy mb-4">Smart Coupon Management</h3>
                <p className="text-gray-600 leading-relaxed">
                  Design and distribute targeted digital coupons with expiration dates, usage limits, and location-based triggers for maximum impact.
                </p>
              </CardContent>
            </Card>

            <Card className="hover:shadow-xl transition-shadow duration-300 group">
              <CardContent className="p-8">
                <div className="bg-gradient-to-r from-accent-cyan to-primary-blue w-12 h-12 rounded-lg flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                  <Shield className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-dark-navy mb-4">Secure Authentication</h3>
                <p className="text-gray-600 leading-relaxed">
                  Advanced security features protect customer data and prevent fraud with encrypted transactions and secure verification methods.
                </p>
              </CardContent>
            </Card>

            <Card className="hover:shadow-xl transition-shadow duration-300 group">
              <CardContent className="p-8">
                <div className="bg-gradient-to-r from-primary-blue to-primary-cyan w-12 h-12 rounded-lg flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                  <BarChart3 className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-dark-navy mb-4">Real-Time Analytics</h3>
                <p className="text-gray-600 leading-relaxed">
                  Get detailed insights into customer behavior, program performance, and ROI with comprehensive reporting and analytics dashboard.
                </p>
              </CardContent>
            </Card>

            <Card className="hover:shadow-xl transition-shadow duration-300 group">
              <CardContent className="p-8">
                <div className="bg-gradient-to-r from-primary-cyan to-accent-cyan w-12 h-12 rounded-lg flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                  <Zap className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-dark-navy mb-4">Easy Distribution</h3>
                <p className="text-gray-600 leading-relaxed">
                  Multiple distribution channels including QR codes, email campaigns, SMS, social media sharing, and in-store sign-ups.
                </p>
              </CardContent>
            </Card>

            <Card className="hover:shadow-xl transition-shadow duration-300 group">
              <CardContent className="p-8">
                <div className="bg-gradient-to-r from-accent-cyan to-primary-blue w-12 h-12 rounded-lg flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                  <Settings className="w-6 h-6 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-dark-navy mb-4">Custom Branding</h3>
                <p className="text-gray-600 leading-relaxed">
                  Fully customize your loyalty cards and coupons with your brand colors, logo, and messaging to maintain consistent brand identity.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Integrations Section */}
      <section id="integrations" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-dark-navy mb-4">
              Seamless{" "}
              <span className="bg-gradient-to-r from-primary-blue to-primary-cyan bg-clip-text text-transparent">
                Wallet Integration
              </span>
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Your customers' favorite mobile wallets, ready to go. No additional apps to download or accounts to create.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-12 max-w-4xl mx-auto">
            <Card className="bg-gradient-to-br from-gray-900 to-gray-800 text-white shadow-2xl transform hover:scale-105 transition-transform duration-300">
              <CardContent className="p-8 text-center">
                <div className="bg-white w-16 h-16 rounded-xl flex items-center justify-center mx-auto mb-6">
                  <svg className="w-10 h-10 text-gray-900" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                  </svg>
                </div>
                <h3 className="text-2xl font-bold mb-4">Apple Wallet</h3>
                <p className="text-gray-300 mb-6 leading-relaxed">
                  Native integration with Apple Wallet for iOS users. Customers add loyalty cards and coupons with a single tap, and receive notifications right on their lock screen.
                </p>
                <div className="flex items-center justify-center space-x-4 text-sm">
                  <div className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-400 mr-2" />
                    <span>Push Notifications</span>
                  </div>
                  <div className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-400 mr-2" />
                    <span>Location Updates</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-blue-600 to-green-500 text-white shadow-2xl transform hover:scale-105 transition-transform duration-300">
              <CardContent className="p-8 text-center">
                <div className="bg-white w-16 h-16 rounded-xl flex items-center justify-center mx-auto mb-6">
                  <svg className="w-10 h-10 text-gray-900" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                  </svg>
                </div>
                <h3 className="text-2xl font-bold mb-4">Google Wallet</h3>
                <p className="text-gray-100 mb-6 leading-relaxed">
                  Seamless Android integration with Google Wallet. Automatic updates, geolocation features, and instant access from any Android device.
                </p>
                <div className="flex items-center justify-center space-x-4 text-sm">
                  <div className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-300 mr-2" />
                    <span>Auto Updates</span>
                  </div>
                  <div className="flex items-center">
                    <CheckCircle className="w-4 h-4 text-green-300 mr-2" />
                    <span>Geolocation</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          <div className="text-center mt-12">
            <p className="text-gray-600 text-lg mb-6">
              Works on all major mobile platforms. Your customers don't need to download any additional apps.
            </p>
            <div className="flex justify-center items-center space-x-8 text-sm text-gray-500">
              <span>✓ iOS 6+ Compatible</span>
              <span>✓ Android 4.4+ Compatible</span>
              <span>✓ Cross-Platform Sync</span>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section id="testimonials" className="py-20 bg-gradient-to-br from-light-gray to-blue-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-dark-navy mb-4">
              Trusted by{" "}
              <span className="bg-gradient-to-r from-primary-blue to-primary-cyan bg-clip-text text-transparent">
                Local Businesses
              </span>
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              See how GoLoyal is helping businesses just like yours increase customer retention and drive more sales.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="hover:shadow-xl transition-shadow duration-300">
              <CardContent className="p-8">
                <div className="flex items-center mb-6">
                  <div className="flex text-yellow-400">
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} className="w-5 h-5 fill-current" />
                    ))}
                  </div>
                </div>
                <p className="text-gray-600 mb-6 leading-relaxed italic">
                  "GoLoyal transformed our customer retention strategy. We've seen a 40% increase in repeat customers since launching our digital loyalty program. The setup was incredibly easy!"
                </p>
                <div className="flex items-center">
                  <div className="w-12 h-12 rounded-full bg-gradient-to-r from-primary-blue to-primary-cyan flex items-center justify-center mr-4">
                    <Users className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <p className="font-semibold text-dark-navy">Dina Martinez</p>
                    <p className="text-sm text-gray-500">Brew & Bean Coffee</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="hover:shadow-xl transition-shadow duration-300">
              <CardContent className="p-8">
                <div className="flex items-center mb-6">
                  <div className="flex text-yellow-400">
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} className="w-5 h-5 fill-current" />
                    ))}
                  </div>
                </div>
                <p className="text-gray-600 mb-6 leading-relaxed italic">
                  "The analytics dashboard gives us incredible insights into customer behavior. We can track redemption rates and optimize our offers in real-time. Game changer!"
                </p>
                <div className="flex items-center">
                  <div className="w-12 h-12 rounded-full bg-gradient-to-r from-primary-cyan to-accent-cyan flex items-center justify-center mr-4">
                    <Users className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <p className="font-semibold text-dark-navy">Mike Chen</p>
                    <p className="text-sm text-gray-500">Downtown Bistro</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="hover:shadow-xl transition-shadow duration-300">
              <CardContent className="p-8">
                <div className="flex items-center mb-6">
                  <div className="flex text-yellow-400">
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} className="w-5 h-5 fill-current" />
                    ))}
                  </div>
                </div>
                <p className="text-gray-600 mb-6 leading-relaxed italic">
                  "Our customers love how easy it is to use. No more fumbling with physical cards or forgetting them at home. Digital convenience at its finest!"
                </p>
                <div className="flex items-center">
                  <div className="w-12 h-12 rounded-full bg-gradient-to-r from-accent-cyan to-primary-blue flex items-center justify-center mr-4">
                    <Users className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <p className="font-semibold text-dark-navy">Emily Johnson</p>
                    <p className="text-sm text-gray-500">Trendy Threads Boutique</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* CTA Footer Section */}
      <section id="cta" className="py-20 bg-gradient-to-r from-primary-blue to-primary-cyan">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-6">
            Ready to Transform Your Customer Experience?
          </h2>
          <p className="text-xl text-blue-100 mb-8 leading-relaxed">
            Join thousands of local businesses already using GoLoyal to increase customer retention and drive more sales.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Button
              size="lg"
              className="bg-white text-primary-blue hover:shadow-xl transition-all duration-300 transform hover:scale-105 text-lg px-8 py-4"
              data-testid="button-start-free-trial"
            >
              Start Free Trial
            </Button>
            <Button
              size="lg"
              className="bg-white text-primary-blue hover:shadow-xl transition-all duration-300 transform hover:scale-105 text-lg px-8 py-4"
              onClick={() => scrollToSection("demo-form")}
              data-testid="button-schedule-demo"
            >
              Schedule Demo
            </Button>
          </div>

          {/* Demo Request Form */}
          <Card className="bg-white/10 backdrop-blur-sm max-w-md mx-auto" id="demo-form">
            <CardContent className="p-8">
              <h3 className="text-xl font-semibold text-white mb-6">Get a Personalized Demo</h3>
              <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                  <FormField
                    control={form.control}
                    name="businessName"
                    render={({ field }) => (
                      <FormItem>
                        <FormControl>
                          <Input
                            placeholder="Business Name"
                            className="bg-white/90 border-0 focus:ring-2 focus:ring-white/50"
                            data-testid="input-business-name"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name="contactName"
                    render={({ field }) => (
                      <FormItem>
                        <FormControl>
                          <Input
                            placeholder="Your Name"
                            className="bg-white/90 border-0 focus:ring-2 focus:ring-white/50"
                            data-testid="input-contact-name"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name="email"
                    render={({ field }) => (
                      <FormItem>
                        <FormControl>
                          <Input
                            type="email"
                            placeholder="Email Address"
                            className="bg-white/90 border-0 focus:ring-2 focus:ring-white/50"
                            data-testid="input-email"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name="phone"
                    render={({ field }) => (
                      <FormItem>
                        <FormControl>
                          <Input
                            type="tel"
                            placeholder="Phone Number"
                            className="bg-white/90 border-0 focus:ring-2 focus:ring-white/50"
                            data-testid="input-phone"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <Button
                    type="submit"
                    className="w-full bg-white text-primary-blue hover:shadow-lg transition-all duration-200 transform hover:scale-105"
                    disabled={demoRequestMutation.isPending}
                    data-testid="button-request-demo"
                  >
                    {demoRequestMutation.isPending ? "Requesting..." : "Request Demo"}
                  </Button>
                </form>
              </Form>
              <p className="text-blue-100 text-sm mt-4">
                No spam, ever. We'll show you exactly how GoLoyal can work for your business.
              </p>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-dark-navy text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-4 gap-8">
            <div className="col-span-2">
              <div className="flex items-center space-x-3 mb-6">
                <img
                  src={isDarkMode ? goLoyalLogoDark : goLoyalLogoLight}
                  alt="GoLoyal Logo"
                  className="h-8 w-auto"
                />
                <span className="text-2xl font-bold bg-gradient-to-r from-primary-blue to-primary-cyan bg-clip-text text-transparent">
                  GoLoyal
                </span>
              </div>
              <p className="text-gray-300 mb-6 leading-relaxed max-w-md">
                Empowering local businesses with digital loyalty programs that customers love. Seamlessly integrate with Apple Wallet and Google Wallet.
              </p>
            </div>

            <div>
              <h4 className="font-semibold text-lg mb-4">Product</h4>
              <ul className="space-y-2">
                <li>
                  <button
                    onClick={() => scrollToSection("features")}
                    className="text-gray-300 hover:text-white transition-colors"
                  >
                    Features
                  </button>
                </li>
                <li>
                  <button className="text-gray-300 hover:text-white transition-colors">
                    Pricing
                  </button>
                </li>
                <li>
                  <button
                    onClick={() => scrollToSection("integrations")}
                    className="text-gray-300 hover:text-white transition-colors"
                  >
                    Integrations
                  </button>
                </li>
                <li>
                  <button className="text-gray-300 hover:text-white transition-colors">
                    API
                  </button>
                </li>
              </ul>
            </div>

            <div>
              <h4 className="font-semibold text-lg mb-4">Support</h4>
              <ul className="space-y-2">
                <li>
                  <button className="text-gray-300 hover:text-white transition-colors">
                    Help Center
                  </button>
                </li>
                <li>
                  <button className="text-gray-300 hover:text-white transition-colors">
                    Contact Us
                  </button>
                </li>
                <li>
                  <button className="text-gray-300 hover:text-white transition-colors">
                    Privacy Policy
                  </button>
                </li>
                <li>
                  <button className="text-gray-300 hover:text-white transition-colors">
                    Terms of Service
                  </button>
                </li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-700 mt-12 pt-8 text-center">
            <p className="text-gray-400">
              © 2024 GoLoyal. All rights reserved. Built with ❤️ for local businesses.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
