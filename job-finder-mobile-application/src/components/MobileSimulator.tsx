/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useRef } from 'react';
import { 
  Wifi, Battery, MapPin, Search, SlidersHorizontal, Volume2, Phone, 
  CheckCircle, XCircle, Briefcase, Languages, User, Sparkles, Mic, 
  Map, List, Loader2, ArrowLeft, PlusCircle, Check, HelpCircle, Eye, Hammer, Wrench, Zap, Droplet, Paintbrush, Car, Users, Home, AlertCircle,
  ClipboardList, MessageSquare, Settings, RefreshCw, Bell, LogOut, Plus
} from 'lucide-react';
import { Job, WorkerProfile, EmployerProfile, JobApplication, Language, UserRole } from '../types';
import { SKILL_CATEGORIES, NEPAL_LOCATIONS, INITIAL_JOBS, INITIAL_WORKERS, INITIAL_APPLICATIONS, getLocalData, setLocalData } from '../data';

// Custom sound/speech helper
const speakAloud = (text: string, lang: Language) => {
  if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = lang === 'ne' ? 'ne-NP' : 'en-US';
    utterance.rate = 0.9;
    window.speechSynthesis.speak(utterance);
  }
};

export default function MobileSimulator() {
  // Navigation & User session states
  const [lang, setLang] = useState<Language>(() => getLocalData('lang', 'en'));
  const [screen, setScreen] = useState<string>(() => getLocalData('sim_screen', 'language_selection'));
  const [phone, setPhone] = useState<string>('');
  const [otpSent, setOtpSent] = useState<boolean>(false);
  const [otpCode, setOtpCode] = useState<string>('');
  const [role, setRole] = useState<UserRole | null>(() => getLocalData('sim_role', null));
  const [userId, setUserId] = useState<string>(() => getLocalData('sim_user_id', ''));
  
  // Database mock state (synced to localStorage)
  const [jobs, setJobs] = useState<Job[]>(() => getLocalData('sim_jobs', INITIAL_JOBS));
  const [workers, setWorkers] = useState<WorkerProfile[]>(() => getLocalData('sim_workers', INITIAL_WORKERS));
  const [applications, setApplications] = useState<JobApplication[]>(() => getLocalData('sim_applications', INITIAL_APPLICATIONS));
  const [employers, setEmployers] = useState<EmployerProfile[]>(() => getLocalData('sim_employers', [
    {
      id: 'emp-1',
      name: 'Ravi Ranjan Sah',
      companyName: 'Ravi Construction & Co.',
      phone: '9841234567',
      location: 'Balkumari, Lalitpur',
      isVerified: true,
      type: 'individual',
      role: 'Contractor',
      govId: 'CIT-98412345-NP',
      profilePhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80'
    },
    {
      id: 'emp-2',
      name: 'Abdul Wahab Rain',
      companyName: 'Rain Painting Services',
      phone: '9803214567',
      location: 'Gwarko, Lalitpur',
      isVerified: true,
      type: 'individual',
      role: 'Contractor',
      govId: 'CIT-98032145-NP',
      profilePhoto: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&h=150&q=80'
    },
    {
      id: 'emp-3',
      name: 'Ajay Kumar Sah',
      companyName: 'Sah Electrical Solutions',
      phone: '9851098765',
      location: 'Sanepa, Lalitpur',
      isVerified: true,
      type: 'business',
      role: 'Business Owner',
      govId: 'PAN-98510987-NP',
      profilePhoto: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&h=150&q=80'
    },
    {
      id: 'emp-4',
      name: 'Mohammad Faishal Rain',
      companyName: 'Faishal Heavy Movers',
      phone: '9812345678',
      location: 'Kalanki, Kathmandu',
      isVerified: true,
      type: 'business',
      role: 'Business Owner',
      govId: 'PAN-98123456-NP',
      profilePhoto: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=150&h=150&q=80'
    }
  ]));
  
  // UI filter states (Worker)
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [isMapView, setIsMapView] = useState<boolean>(false);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [maxWageFilter, setMaxWageFilter] = useState<number>(10000);
  const [selectedLocationFilter, setSelectedLocationFilter] = useState<string>('all');
  const [activeJobDetails, setActiveJobDetails] = useState<Job | null>(null);
  
  // Dialog simulated views (Voice Parsing, Calling, Custom messaging)
  const [voiceInputOpen, setVoiceInputOpen] = useState<boolean>(false);
  const [speechText, setSpeechText] = useState<string>('');
  const [parsingVoice, setParsingVoice] = useState<boolean>(false);
  const [voiceParsedProfile, setVoiceParsedProfile] = useState<Partial<WorkerProfile> | null>(null);
  const [callingPhone, setCallingPhone] = useState<string | null>(null);
  const [callingName, setCallingName] = useState<string | null>(null);

  // Tab states for worker and employer
  const [workerTab, setWorkerTab] = useState<'jobs' | 'applications' | 'chat' | 'sync' | 'profile'>('jobs');
  const [employerTab, setEmployerTab] = useState<'jobs' | 'post' | 'applicants' | 'chat' | 'sync' | 'profile'>('jobs');

  // Employer Profile Setup Screen states
  const [empSetupName, setEmpSetupName] = useState<string>('');
  const [empSetupRole, setEmpSetupRole] = useState<string>('Contractor');
  const [empSetupCompany, setEmpSetupCompany] = useState<string>('');
  const [empSetupLocation, setEmpSetupLocation] = useState<string>('Balkumari, Lalitpur');
  const [empSetupGovIdType, setEmpSetupGovIdType] = useState<string>('citizenship');
  const [empSetupGovIdNum, setEmpSetupGovIdNum] = useState<string>('');
  const [empSetupGovIdFile, setEmpSetupGovIdFile] = useState<string>('');
  const [empSetupPhoto, setEmpSetupPhoto] = useState<string>('');

  // Employer Profile Edit states
  const [isEditingProfile, setIsEditingProfile] = useState<boolean>(false);
  const [editEmpName, setEditEmpName] = useState<string>('');
  const [editEmpRole, setEditEmpRole] = useState<string>('Contractor');
  const [editEmpCompany, setEditEmpCompany] = useState<string>('');
  const [editEmpLocation, setEditEmpLocation] = useState<string>('Balkumari, Lalitpur');
  const [editEmpGovId, setEditEmpGovId] = useState<string>('');
  const [editEmpPhoto, setEditEmpPhoto] = useState<string>('');
  const [editEmpPhone, setEditEmpPhone] = useState<string>('');

  // Worker Profile Edit states
  const [editWorkerName, setEditWorkerName] = useState<string>('');
  const [editWorkerPhone, setEditWorkerPhone] = useState<string>('');
  const [editWorkerWage, setEditWorkerWage] = useState<string>('');
  const [editWorkerRole, setEditWorkerRole] = useState<string>('laborer');
  const [editWorkerLocation, setEditWorkerLocation] = useState<string>('Balkumari, Lalitpur');
  const [editWorkerGovId, setEditWorkerGovId] = useState<string>('');
  const [editWorkerPhoto, setEditWorkerPhoto] = useState<string>('');
  const [editWorkerBio, setEditWorkerBio] = useState<string>('');

  // System settings state variables
  const [voiceFeedbackEnabled, setVoiceFeedbackEnabled] = useState<boolean>(() => getLocalData('sys_voice_feedback', true));
  const [soundAlertsEnabled, setSoundAlertsEnabled] = useState<boolean>(() => getLocalData('sys_sound_alerts', true));
  const [themePref, setThemePref] = useState<'system' | 'light' | 'dark'>(() => getLocalData('sys_theme_pref', 'light'));
  const [systemIsDark, setSystemIsDark] = useState<boolean>(false);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
      setSystemIsDark(mediaQuery.matches);
      const listener = (e: MediaQueryListEvent) => setSystemIsDark(e.matches);
      mediaQuery.addEventListener('change', listener);
      return () => mediaQuery.removeEventListener('change', listener);
    }
  }, []);

  useEffect(() => {
    setLocalData('sys_theme_pref', themePref);
  }, [themePref]);

  const isDark = themePref === 'dark' || (themePref === 'system' && systemIsDark);


  // Match logs and sync states
  const [matchLogs, setMatchLogs] = useState<string[]>([]);
  const [isSyncing, setIsSyncing] = useState<boolean>(false);
  const [syncProgress, setSyncProgress] = useState<number>(100);
  const [lastSyncTime, setLastSyncTime] = useState<string>('Never');
  const [isOnline, setIsOnline] = useState<boolean>(true);

  // Chat states
  const [activeChatChannel, setActiveChatChannel] = useState<string | null>(null);
  const [chatMessages, setChatMessages] = useState<{[key: string]: {sender: 'user' | 'other', text: string, time: string}[]}>({
    'Ravi Ranjan Sah': [
      { sender: 'other', text: 'Namaste! Are you available for a painting job tomorrow?', time: 'Yesterday' },
      { sender: 'user', text: 'Yes, I am available. What is the location?', time: 'Yesterday' },
      { sender: 'other', text: 'Balkumari, Lalitpur. Daily wage is Rs. 1200.', time: 'Yesterday' }
    ],
    'Ajay Kumar Sah': [
      { sender: 'other', text: 'Hi, we saw your profile. Do you do wiring for DB boxes?', time: '2 days ago' }
    ],
    'Hari Bahadur Shrestha': [
      { sender: 'other', text: 'Hi Sir, I saw your job post for brick layers. Is it still open?', time: 'Yesterday' }
    ]
  });
  const [newMsgText, setNewMsgText] = useState<string>('');

  const [postTitle, setPostTitle] = useState<string>('');
  const [postCategory, setPostCategory] = useState<string>('mason');
  const [postWage, setPostWage] = useState<number>(1200);
  const [postLocation, setPostLocation] = useState<string>('Balkumari, Lalitpur');
  const [postDesc, setPostDesc] = useState<string>('');

  // Clock state
  const [time, setTime] = useState<string>('12:00');

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false }));
    };
    updateTime();
    const interval = setInterval(updateTime, 60000);
    return () => clearInterval(interval);
  }, []);

  // Persist databases whenever changed
  useEffect(() => {
    setLocalData('sim_jobs', jobs);
  }, [jobs]);

  useEffect(() => {
    setLocalData('sim_workers', workers);
  }, [workers]);

  useEffect(() => {
    setLocalData('sim_applications', applications);
  }, [applications]);

  useEffect(() => {
    setLocalData('sim_employers', employers);
  }, [employers]);

  useEffect(() => {
    setLocalData('lang', lang);
  }, [lang]);

  useEffect(() => {
    setLocalData('sys_voice_feedback', voiceFeedbackEnabled);
  }, [voiceFeedbackEnabled]);

  useEffect(() => {
    setLocalData('sys_sound_alerts', soundAlertsEnabled);
  }, [soundAlertsEnabled]);

  useEffect(() => {
    setLocalData('sim_screen', screen);
  }, [screen]);

  useEffect(() => {
    setLocalData('sim_role', role);
  }, [role]);

  useEffect(() => {
    setLocalData('sim_user_id', userId);
  }, [userId]);

  // Voice recognition simulation presets to test Gemini Parsing API
  const PRESET_DICTATIONS = [
    {
      labelEn: "Dictate: Suresh Kumar BK, Painter, Balkumari, 1100 per day",
      labelNe: "बोल्नुहोस्: सुरेश कुमार विक, पेन्टर, बालकुमारी, दिनको ११००",
      textEn: "My name is Suresh Kumar BK. I am an experienced house painter from Balkumari Lalitpur. I am looking for exterior or interior painting jobs. My daily wage expectation is eleven hundred rupees. I am ready to start immediately.",
      textNe: "मेरो नाम सुरेश कुमार विक हो। म बालकुमारी ललितपुरमा बस्छु र म पेन्टरको काम गर्छु। मलाई रंगरोगनको काममा २ वर्षको अनुभव छ। मलाई प्रतिदिन एघार सय रुपैयाँ ज्याला चाहिन्छ र म तुरुन्तै काम गर्न सक्छु।"
    },
    {
      labelEn: "Dictate: Ram Bahadur, Plumber, Sanepa, 1500 per day",
      labelNe: "बोल्नुहोस्: राम बहादुर, प्लम्बर, सानेपा, दिनको १५००",
      textEn: "Hello, I am Ram Bahadur. I am a plumber living in Sanepa Lalitpur. I have a tool kit and can do complete pipe fitting and leakage repairs. I expect fifteen hundred rupees daily pay.",
      textNe: "नमस्ते म राम बहादुर हो। म सानेपा ललितपुरमा बस्ने प्लम्बर कामदार हुँ। म खानेपानी पाइप फिटिङ र चुहावट मर्मतको काम गर्छु। मेरो दैनिक ज्याला १५०० रुपैयाँ हो।"
    }
  ];

  // Call Express API route to parse voice using Gemini
  const handleVoiceParse = async (text: string) => {
    setParsingVoice(true);
    try {
      const res = await fetch('/api/voice-parse', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ speechText: text, language: lang })
      });
      const data = await res.json();
      if (res.ok) {
        setVoiceParsedProfile(data);
      } else {
        alert("Parsing failed. Using local manual builder.");
      }
    } catch (err) {
      console.error(err);
      // Fallback local parse
      setVoiceParsedProfile({
        name: lang === 'ne' ? "हरि थापा" : "Hari Thapa",
        mainSkill: "electrician",
        experience: "3 Years",
        expectedWage: 1200,
        location: "Balkumari, Lalitpur",
        bio: "Simulated extraction: " + text
      });
    } finally {
      setParsingVoice(false);
    }
  };

  // Quick Action methods
  const handleSendOtp = () => {
    if (phone.length < 10) {
      alert(lang === 'ne' ? 'कृपया १० अंकको सहि मोबाइल नम्बर हाल्नुहोस्।' : 'Please enter a valid 10-digit mobile number.');
      return;
    }
    setOtpSent(true);
  };

  const handleVerifyOtp = () => {
    if (otpCode !== '123456' && otpCode.trim() !== '') {
      alert(lang === 'ne' ? 'गलत ओटिपी कोड! कृपया १२३४५६ प्रयोग गर्नुहोस्।' : 'Invalid OTP. Please use 123456 to login.');
      return;
    }
    // Set mock user id based on phone
    const mockId = `worker-${phone}`;
    setUserId(mockId);
    
    // Check if worker already has a profile
    const existing = workers.find(w => w.phone === phone);
    if (existing) {
      setRole('worker');
      setScreen('worker_home');
    } else {
      setScreen('role_selection');
    }
  };

  const handleCreateWorkerProfile = (profileData: Partial<WorkerProfile>) => {
    const newProfile: WorkerProfile = {
      id: `worker-${Date.now()}`,
      name: profileData.name || 'Anonymous Worker',
      phone: phone || '9845112233',
      mainSkill: profileData.mainSkill || 'laborer',
      experience: profileData.experience || 'Fresher',
      expectedWage: profileData.expectedWage || 1000,
      expectedWageType: 'daily',
      location: profileData.location || 'Balkumari, Lalitpur',
      availability: 'Immediate',
      bio: profileData.bio || 'Willing to work hard.'
    };
    setWorkers(prev => [...prev, newProfile]);
    setRole('worker');
    setScreen('worker_home');
    setVoiceInputOpen(false);
    setVoiceParsedProfile(null);
    setSpeechText('');
  };

  const handleUpdateWorkerProfile = (updatedData: Partial<WorkerProfile>) => {
    setWorkers(prev => prev.map(w => {
      const currentActivePhone = phone || '9845551122';
      if (w.phone === currentActivePhone || w.id === userId) {
        return {
          ...w,
          ...updatedData
        };
      }
      return w;
    }));
    setIsEditingProfile(false);
  };

  const handleCreateEmployerProfile = (profileData: Partial<EmployerProfile>) => {
    const newProfile: EmployerProfile = {
      id: `emp-${Date.now()}`,
      name: profileData.name || 'Anonymous Employer',
      companyName: profileData.companyName || 'Individual Project',
      phone: phone || '9851012345',
      location: profileData.location || 'Balkumari, Lalitpur',
      isVerified: true,
      type: profileData.type || 'individual',
      role: profileData.role || 'Contractor',
      govId: profileData.govId || 'CIT-12345-NP',
      profilePhoto: profileData.profilePhoto || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80'
    };
    setEmployers(prev => [...prev, newProfile]);
    setRole('employer');
    setScreen('employer_home');
  };

  const handleUpdateEmployerProfile = (updatedData: Partial<EmployerProfile>) => {
    setEmployers(prev => prev.map(emp => {
      // Find by matching phone (or fallback/id)
      const currentActivePhone = phone || '9851044321';
      const targetPhone = emp.phone;
      if (targetPhone === currentActivePhone || emp.id === 'emp-1' || emp.phone === phone) {
        return {
          ...emp,
          ...updatedData,
          // maintain isVerified if it was verified, or force verified
          isVerified: true
        };
      }
      return emp;
    }));
    setIsEditingProfile(false);
  };

  const handleApplyForJob = (jobId: string) => {
    const activeWorker = workers.find(w => w.phone === phone) || workers[0];
    const newApp: JobApplication = {
      id: `app-${Date.now()}`,
      jobId: jobId,
      workerId: activeWorker?.id || 'work-1',
      workerName: activeWorker?.name || 'Hari Bahadur Shrestha',
      workerPhone: activeWorker?.phone || '9845551122',
      workerSkill: activeWorker?.mainSkill || 'Mason',
      status: 'pending',
      appliedAt: new Date().toISOString()
    };
    
    setApplications(prev => [...prev, newApp]);
    speakAloud(
      lang === 'ne' 
        ? "आवेदन सफलतापूर्वक पठाइयो। रोजगारदाताले छिट्टै सम्पर्क गर्नेछ।" 
        : "Application submitted successfully. The employer will contact you shortly.", 
      lang
    );
  };

  const handlePostJob = (e: React.FormEvent) => {
    e.preventDefault();
    if (!postTitle.trim()) return;

    const newJob: Job = {
      id: `job-${Date.now()}`,
      title: postTitle,
      category: postCategory,
      description: postDesc || `Urgent need for a skilled ${postCategory} at ${postLocation}.`,
      wage: postWage,
      wageType: 'daily',
      location: postLocation,
      employerId: 'emp-verified',
      employerName: 'NCIT Construction Group',
      employerPhone: phone || '9851012345',
      employerWhatsApp: phone || '9851012345',
      requiredSkills: [postCategory, 'Manual Labor', 'Safety Gear'],
      datePosted: new Date().toISOString(),
      lat: 27.6715 + (Math.random() - 0.5) * 0.02,
      lng: 85.3395 + (Math.random() - 0.5) * 0.02,
      applicantsCount: 0
    };

    setJobs(prev => [newJob, ...prev]);
    setPostTitle('');
    setPostDesc('');
    setEmployerTab('post');
    alert(lang === 'ne' ? 'काम सफलतापूर्वक थपियो!' : 'Job posted successfully!');
  };

  const handleUpdateApplicantStatus = (appId: string, status: 'accepted' | 'rejected') => {
    setApplications(prev => prev.map(app => app.id === appId ? { ...app, status } : app));
  };

  const handleSendChatMessage = (channel: string) => {
    if (!newMsgText.trim()) return;
    const nowStr = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    
    // Add user message
    setChatMessages(prev => ({
      ...prev,
      [channel]: [
        ...(prev[channel] || []),
        { sender: 'user', text: newMsgText, time: nowStr }
      ]
    }));
    
    setNewMsgText('');

    // Simulate reply after 1.5 seconds
    setTimeout(() => {
      let reply = "Namaste! Please call me directly to discuss.";
      if (lang === 'ne') {
        reply = "नमस्ते! थप कुराकानीको लागि कृपया मलाई सिधै फोन गर्नुहोस्।";
      }

      if (channel === 'Ravi Ranjan Sah') {
        reply = lang === 'ne' 
          ? "हुन्छ, भोलि बिहान ७ बजे साइटमा आउनुहोला। सम्पर्क नम्बर: ९८४१२३४५६७।" 
          : "Great! Please come to the Balkumari site tomorrow morning at 7 AM. Call me at 9841234567.";
      } else if (channel === 'Ajay Kumar Sah') {
        reply = lang === 'ne' 
          ? "काम राम्रो छ, एकपटक सानेपा आइदिनुहोस्।" 
          : "The wiring work is standard. Please meet me once at Sanepa.";
      } else if (channel === 'Hari Bahadur Shrestha') {
        reply = lang === 'ne' 
          ? "हो काम बाँकी छ, भोलिदेखि सुरु गर्न सक्नुहुन्छ?" 
          : "Yes, the bricklaying work is still available. Can you start tomorrow?";
      }

      setChatMessages(prev => ({
        ...prev,
        [channel]: [
          ...(prev[channel] || []),
          { sender: 'other', text: reply, time: nowStr }
        ]
      }));

      // Speak reply aloud
      speakAloud(reply, lang);
    }, 1500);
  };

  const handleSyncDatabase = () => {
    if (isSyncing) return;
    setIsSyncing(true);
    setSyncProgress(0);
    
    let currentProgress = 0;
    const interval = setInterval(() => {
      currentProgress += 10;
      setSyncProgress(currentProgress);
      if (currentProgress >= 100) {
        clearInterval(interval);
        setIsSyncing(false);
        const now = new Date();
        setLastSyncTime(now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }));
        
        // Add a simulation log
        const logMsg = lang === 'ne' 
          ? `[${now.toLocaleTimeString()}] नयाँ मिल्दो काम भेटियो: रंगरोगन कामदार (पेन्टर) ललितपुर!` 
          : `[${now.toLocaleTimeString()}] Matched 1 new local job: Painter needed at Gwarko!`;
        
        setMatchLogs(prev => [logMsg, ...prev]);
        speakAloud(
          lang === 'ne' 
            ? "अफलाईन सिन्क्रोनाइजेसन सफल भयो। नयाँ काम थपियो।" 
            : "Offline synchronization completed. New matched job alerts downloaded.",
          lang
        );
      }
    }, 150);
  };

  // Speech Synthesizer call
  const handlePlayJobAudio = (job: Job) => {
    const voiceText = lang === 'ne' 
      ? `कामको विवरण: ${job.title}. ज्याला दैनिक ${job.wage} रुपैयाँ। ठेगाना: ${job.location}. कामको बारेमा: ${job.description}`
      : `Job title: ${job.title}. Wage expectation is ${job.wage} rupees per day. Job location is ${job.location}. Description: ${job.description}`;
    speakAloud(voiceText, lang);
  };

  // Category Icon Lookup
  const getCatIcon = (catId: string) => {
    switch (catId) {
      case 'mason': return <Hammer className="h-5 w-5" />;
      case 'carpenter': return <Wrench className="h-5 w-5" />;
      case 'electrician': return <Zap className="h-5 w-5" />;
      case 'plumber': return <Droplet className="h-5 w-5" />;
      case 'painter': return <Paintbrush className="h-5 w-5" />;
      case 'driver': return <Car className="h-5 w-5" />;
      case 'laborer': return <Users className="h-5 w-5" />;
      case 'domestic': return <Home className="h-5 w-5" />;
      default: return <Briefcase className="h-5 w-5" />;
    }
  };

  // Filter logic
  const filteredJobs = jobs.filter(job => {
    if (selectedCategory !== 'all' && job.category !== selectedCategory) return false;
    if (selectedLocationFilter !== 'all' && job.location !== selectedLocationFilter) return false;
    if (job.wage > maxWageFilter) return false;
    if (searchQuery.trim() !== '') {
      const q = searchQuery.toLowerCase();
      const matchTitle = job.title.toLowerCase().includes(q);
      const matchLoc = job.location.toLowerCase().includes(q);
      const matchDesc = job.description.toLowerCase().includes(q);
      if (!matchTitle && !matchLoc && !matchDesc) return false;
    }
    return true;
  });

  return (
    <div className={`relative mx-auto w-[365px] h-[720px] bg-black rounded-[48px] border-[10px] border-[#1C1C21] shadow-2xl shadow-black ring-1 ring-white/10 flex flex-col overflow-hidden select-none ${isDark ? 'dark' : ''}`} id="mobile_sim_frame">
      {/* Phone Camera Bezel Notch */}
      <div className="absolute top-2 left-1/2 -translate-x-1/2 w-32 h-5 bg-slate-950 rounded-full z-50 flex items-center justify-center">
        <div className="w-3 h-3 bg-slate-900 rounded-full border border-slate-800 ml-16" />
      </div>

      {/* Status Bar */}
      <div className="h-10 bg-[#0F0F12] border-b border-white/5 text-white flex items-center justify-between px-6 pt-3 text-xs font-medium z-40 select-none">
        <span>{time}</span>
        <div className="flex items-center gap-1.5">
          <Wifi className="h-3.5 w-3.5 text-slate-300" />
          <span className="text-[10px] text-slate-300 font-bold">5G</span>
          <div className="flex items-center gap-0.5">
            <Battery className="h-4 w-4 text-indigo-400 fill-indigo-400" />
            <span className="text-[9px]">100%</span>
          </div>
        </div>
      </div>

      {/* Screen Wrapper (Scrollable view inside the phone) */}
      <div className="flex-1 bg-slate-50 flex flex-col overflow-y-auto overflow-x-hidden relative" id="mobile_sim_screen_content">
        
        {/* ==================== SCREEN: LANGUAGE SELECTION ==================== */}
        {screen === 'language_selection' && (
          <div className="flex-1 flex flex-col p-6 text-center justify-between">
            <div className="my-auto space-y-6">
              <div className="mx-auto w-20 h-20 rounded-full bg-slate-900/5 flex items-center justify-center">
                <Briefcase className="h-10 w-10 text-slate-900" />
              </div>
              <div className="space-y-1">
                <h1 className="text-2xl font-black text-slate-900 tracking-tight">Job Finder</h1>
                <p className="text-sm font-semibold text-slate-500">जागिर खोज्ने मोबाइल एप</p>
                <p className="text-xs text-slate-400">For Unskilled & Semi-Skilled Workers</p>
              </div>
            </div>

            <div className="space-y-4 pb-8">
              <p className="text-xs font-bold text-slate-500 tracking-wider uppercase">Select Language / भाषा छान्नुहोस्</p>
              
              {/* English Selection */}
              <button
                onClick={() => {
                  setLang('en');
                  setScreen('login');
                }}
                className="w-full py-4 rounded-2xl bg-slate-900 text-white font-bold flex items-center justify-center gap-3 shadow-md hover:bg-slate-800 transition-all transform active:scale-95 border-b-4 border-slate-950"
              >
                <span className="text-lg">🇺🇸</span>
                <span>English</span>
              </button>

              {/* Nepali Selection */}
              <button
                onClick={() => {
                  setLang('ne');
                  setScreen('login');
                }}
                className="w-full py-4 rounded-2xl bg-white text-slate-900 font-bold flex items-center justify-center gap-3 border-2 border-slate-200 shadow-sm hover:border-slate-300 transition-all transform active:scale-95 border-b-4 border-slate-200"
              >
                <span className="text-lg">🇳🇵</span>
                <span className="font-hindi text-base font-bold">नेपाली (Nepali)</span>
              </button>
            </div>
          </div>
        )}

        {/* ==================== SCREEN: LOGIN ==================== */}
        {screen === 'login' && (
          <div className="flex-1 flex flex-col p-6 justify-between">
            <div className="space-y-6">
              <button 
                onClick={() => setScreen('language_selection')}
                className="flex items-center gap-1 text-slate-500 text-xs font-bold hover:text-slate-800"
              >
                <ArrowLeft className="h-4 w-4" />
                <span>{lang === 'ne' ? 'भाषा परिवर्तन' : 'Change Language'}</span>
              </button>

              <div className="space-y-1">
                <h1 className="text-2xl font-extrabold text-slate-900 tracking-tight">
                  {lang === 'ne' ? 'मोबाईल लग-इन' : 'Mobile Login'}
                </h1>
                <p className="text-xs text-slate-500 leading-relaxed">
                  {lang === 'ne' 
                    ? 'सुरक्षित प्रवेशको लागि आफ्नो मोबाइल नम्बर राख्नुहोस्। पासवर्ड चाहिँदैन।' 
                    : 'Enter your 10-digit mobile number. No email or passwords required.'}
                </p>
              </div>

              <div className="space-y-4 pt-4">
                <div>
                  <label className="text-[11px] font-bold text-slate-500 uppercase tracking-wider block mb-1.5">
                    {lang === 'ne' ? 'नेपाली मोबाइल नम्बर' : 'Nepali Mobile Number'}
                  </label>
                  <div className="flex items-center gap-2">
                    <span className="bg-slate-100 px-3 py-3.5 rounded-xl border border-slate-200 text-sm font-bold text-slate-600">
                      +977
                    </span>
                    <input
                      type="tel"
                      maxLength={10}
                      placeholder="98XXXXXXXX"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value.replace(/\D/g, ''))}
                      className="flex-1 bg-white px-4 py-3.5 rounded-xl border border-slate-200 text-sm font-bold focus:border-slate-900 focus:outline-none focus:ring-1 focus:ring-slate-900 shadow-inner"
                    />
                  </div>
                </div>

                {otpSent && (
                  <div className="space-y-1.5 animate-fadeIn">
                    <div className="flex justify-between items-center">
                      <label className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                        {lang === 'ne' ? '६-अंकको ओटिपी कोड हाल्नुहोस्' : '6-Digit OTP Code'}
                      </label>
                      <span className="text-[10px] text-emerald-600 font-bold">Code sent: 123456</span>
                    </div>
                    <input
                      type="text"
                      maxLength={6}
                      placeholder="******"
                      value={otpCode}
                      onChange={(e) => setOtpCode(e.target.value.replace(/\D/g, ''))}
                      className="w-full text-center tracking-widest bg-white px-4 py-3 rounded-xl border border-slate-200 text-lg font-bold focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500"
                    />
                  </div>
                )}
              </div>
            </div>

            <div className="pb-4">
              <button
                onClick={otpSent ? handleVerifyOtp : handleSendOtp}
                className="w-full py-4 rounded-xl bg-slate-900 text-white font-bold text-sm shadow-md hover:bg-slate-800 transition-all transform active:scale-95 border-b-4 border-slate-950"
              >
                {otpSent 
                  ? (lang === 'ne' ? 'कोड प्रमाणित गर्नुहोस्' : 'Verify & Proceed') 
                  : (lang === 'ne' ? 'ओटिपी पठाउनुहोस्' : 'Send OTP Verification Code')}
              </button>
            </div>
          </div>
        )}

        {/* ==================== SCREEN: ROLE SELECTION ==================== */}
        {screen === 'role_selection' && (
          <div className="flex-1 flex flex-col p-6 justify-between">
            <div className="text-center space-y-2 mt-4">
              <h1 className="text-2xl font-black text-slate-900">{lang === 'ne' ? 'तपाईं को हुनुहुन्छ?' : 'Who are you?'}</h1>
              <p className="text-xs text-slate-500">{lang === 'ne' ? 'आफ्नो आवश्यकता अनुसार भूमिका चयन गर्नुहोस्।' : 'Select the portal that fits your needs.'}</p>
            </div>

            <div className="space-y-4 my-auto">
              {/* Option 1: Worker / Job Seeker */}
              <button
                onClick={() => {
                  const existingWorker = workers.find(w => w.phone === phone);
                  if (existingWorker) {
                    setRole('worker');
                    setScreen('worker_home');
                  } else {
                    setScreen('worker_profile_creation');
                  }
                }}
                className="w-full p-5 rounded-2xl bg-white border border-slate-200 shadow-sm text-left hover:border-emerald-500 hover:ring-1 hover:ring-emerald-500 transition-all flex items-start gap-4 transform active:scale-95"
              >
                <div className="p-3 rounded-xl bg-emerald-50 text-emerald-600">
                  <User className="h-6 w-6" />
                </div>
                <div className="space-y-1">
                  <h2 className="text-sm font-extrabold text-slate-950">
                    {lang === 'ne' ? 'जागिर खोज्ने (कामदार)' : 'Job Seeker (Worker)'}
                  </h2>
                  <p className="text-[11px] text-slate-500 leading-relaxed">
                    {lang === 'ne' 
                      ? 'डकर्मी, पेन्टर, इलेक्ट्रीशियन, लेबर आदि कामहरू पाउनुहोस्।' 
                      : 'Find immediate daily wage or construction works near Lalitpur.'}
                  </p>
                </div>
              </button>

              {/* Option 2: Employer */}
              <button
                onClick={() => {
                  const existingEmployer = employers.find(e => e.phone === phone);
                  if (existingEmployer) {
                    setRole('employer');
                    setScreen('employer_home');
                  } else {
                    setScreen('employer_profile_creation');
                  }
                }}
                className="w-full p-5 rounded-2xl bg-white border border-slate-200 shadow-sm text-left hover:border-slate-900 hover:ring-1 hover:ring-slate-900 transition-all flex items-start gap-4 transform active:scale-95"
              >
                <div className="p-3 rounded-xl bg-slate-100 text-slate-900">
                  <Briefcase className="h-6 w-6" />
                </div>
                <div className="space-y-1">
                  <h2 className="text-sm font-extrabold text-slate-950">
                    {lang === 'ne' ? 'रोजगारदाता / ठेकेदार' : 'Employer / Contractor'}
                  </h2>
                  <p className="text-[11px] text-slate-500 leading-relaxed">
                    {lang === 'ne' 
                      ? 'आफ्नो निर्माण वा अन्य कामका लागि कामदारहरू भर्ती गर्नुहोस्।' 
                      : 'Post job requirements and connect with skilled laborers.'}
                  </p>
                </div>
              </button>
            </div>

            <div className="pb-2 text-center">
              <p className="text-[10px] text-slate-400">NCIT Minor Project - 2026</p>
            </div>
          </div>
        )}

        {/* ==================== SCREEN: WORKER PROFILE CREATION ==================== */}
        {screen === 'worker_profile_creation' && (
          <div className="flex-1 flex flex-col p-5 bg-slate-50">
            <div className="space-y-3">
              <h1 className="text-xl font-black text-slate-900">{lang === 'ne' ? 'सजिलो प्रोफाइल निर्माण' : 'Simple Profile Setup'}</h1>
              <p className="text-xs text-slate-500">
                {lang === 'ne' 
                  ? 'अक्षर चिन्न गाह्रो छ भने माइक्रोफोन थिचेर बोल्नुहोस्। एआईले आफै फारम भरिदिनेछ!' 
                  : 'Struggle with typing? Tap the microphone to speak your profile! Gemini AI will auto-fill everything.'}
              </p>
            </div>

            {/* Smart AI Voice Box */}
            <div className="mt-4 p-4 rounded-2xl bg-slate-900 text-white relative shadow-md overflow-hidden">
              <div className="absolute top-0 right-0 p-1 bg-gradient-to-l from-emerald-500 to-sky-500 h-1.5 w-full" />
              <div className="flex items-start justify-between">
                <div className="space-y-0.5">
                  <div className="flex items-center gap-1.5 text-xs font-bold text-emerald-400">
                    <Sparkles className="h-3.5 w-3.5 fill-emerald-400" />
                    <span>Gemini Voice Onboarding</span>
                  </div>
                  <p className="text-[10px] text-slate-400">
                    {lang === 'ne' ? 'नेपाली वा अंग्रेजीमा बोल्नुहोस्' : 'Speak in English or Nepali'}
                  </p>
                </div>
                <button
                  onClick={() => setVoiceInputOpen(true)}
                  className="p-2.5 rounded-full bg-slate-800 hover:bg-slate-700 text-emerald-400 transition-colors"
                >
                  <Mic className="h-5 w-5" />
                </button>
              </div>
            </div>

            {/* Standard Profile Creation Form */}
            <form onSubmit={(e) => {
              e.preventDefault();
              const nameInput = (document.getElementById('p_name') as HTMLInputElement)?.value;
              const wageInput = parseInt((document.getElementById('p_wage') as HTMLInputElement)?.value) || 1000;
              const skillInput = (document.getElementById('p_skill') as HTMLSelectElement)?.value || 'laborer';
              const expInput = (document.getElementById('p_exp') as HTMLSelectElement)?.value || 'Fresher';
              const locInput = (document.getElementById('p_loc') as HTMLSelectElement)?.value || 'Balkumari, Lalitpur';
              const bioInput = (document.getElementById('p_bio') as HTMLTextAreaElement)?.value || '';

              handleCreateWorkerProfile({
                name: nameInput,
                expectedWage: wageInput,
                mainSkill: skillInput,
                experience: expInput,
                location: locInput,
                bio: bioInput
              });
            }} className="mt-5 space-y-4 flex-1">
              {/* Full Name */}
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">
                  {lang === 'ne' ? 'कामदारको पूरा नाम' : 'Full Name'}
                </label>
                <input
                  id="p_name"
                  type="text"
                  required
                  defaultValue={voiceParsedProfile?.name || ''}
                  placeholder="Ram Bahadur"
                  className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-slate-900"
                />
              </div>

              {/* Main Skill Dropdown */}
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">
                  {lang === 'ne' ? 'मुख्य सिप' : 'Primary Skill'}
                </label>
                <select
                  id="p_skill"
                  value={voiceParsedProfile?.mainSkill || 'laborer'}
                  onChange={(e) => setVoiceParsedProfile(prev => prev ? { ...prev, mainSkill: e.target.value } : { mainSkill: e.target.value })}
                  className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-slate-900"
                >
                  {SKILL_CATEGORIES.map(cat => (
                    <option key={cat.id} value={cat.id}>
                      {lang === 'ne' ? cat.nameNe : cat.nameEn}
                    </option>
                  ))}
                </select>
              </div>

              {/* Wage and Experience Row */}
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1">
                  <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">
                    {lang === 'ne' ? 'दैनिक ज्याला' : 'Daily Wage (NPR)'}
                  </label>
                  <input
                    id="p_wage"
                    type="number"
                    required
                    defaultValue={voiceParsedProfile?.expectedWage || 1000}
                    placeholder="1000"
                    className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-slate-900"
                  />
                </div>

                <div className="space-y-1">
                  <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">
                    {lang === 'ne' ? 'अनुभव' : 'Experience'}
                  </label>
                  <select
                    id="p_exp"
                    value={voiceParsedProfile?.experience || 'Fresher'}
                    onChange={(e) => setVoiceParsedProfile(prev => prev ? { ...prev, experience: e.target.value } : { experience: e.target.value })}
                    className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none"
                  >
                    <option value="Fresher">{lang === 'ne' ? 'नयाँ (Fresher)' : 'Fresher'}</option>
                    <option value="1 Year">{lang === 'ne' ? '१ वर्ष' : '1 Year'}</option>
                    <option value="2 Years">{lang === 'ne' ? '२ वर्ष' : '2 Years'}</option>
                    <option value="5 Years">{lang === 'ne' ? '५ वर्षभन्दा बढी' : '5+ Years'}</option>
                  </select>
                </div>
              </div>

              {/* Location */}
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">
                  {lang === 'ne' ? 'ठेगाना' : 'Your Location'}
                </label>
                <select
                  id="p_loc"
                  value={voiceParsedProfile?.location || 'Balkumari, Lalitpur'}
                  onChange={(e) => setVoiceParsedProfile(prev => prev ? { ...prev, location: e.target.value } : { location: e.target.value })}
                  className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none"
                >
                  {NEPAL_LOCATIONS.map(loc => (
                    <option key={loc} value={loc}>{loc}</option>
                  ))}
                </select>
              </div>

              {/* Bio */}
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">
                  {lang === 'ne' ? 'आफ्नो बारेमा छोटो जानकारी' : 'Short Bio / Intro'}
                </label>
                <textarea
                  id="p_bio"
                  rows={2}
                  defaultValue={voiceParsedProfile?.bio || ''}
                  placeholder={lang === 'ne' ? 'काम सम्बन्धी अनुभव...' : 'Describe your work availability...'}
                  className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none"
                />
              </div>

              {/* Submit */}
              <button
                type="submit"
                className="w-full py-3.5 mt-2 rounded-xl bg-slate-900 text-white font-bold text-xs hover:bg-slate-800 transition-colors shadow"
              >
                {lang === 'ne' ? 'प्रोफाइल सुरक्षित गर्नुहोस् र अगाडी बढ्नुहोस्' : 'Save Profile & View Jobs'}
              </button>
            </form>
          </div>
        )}

        {/* ==================== SCREEN: EMPLOYER PROFILE CREATION ==================== */}
        {screen === 'employer_profile_creation' && (
          <div className="flex-1 flex flex-col p-5 bg-slate-50 animate-fadeIn justify-between overflow-y-auto">
            <div className="space-y-4">
              {/* Header with back button */}
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setScreen('role_selection')}
                  className="p-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-full transition-colors"
                >
                  <ArrowLeft className="h-4 w-4" />
                </button>
                <div>
                  <h1 className="text-base font-black text-slate-950">
                    {lang === 'ne' ? 'नयाँ रोजगारदाता प्रोफाइल' : 'Employer Profile Setup'}
                  </h1>
                  <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">
                    {lang === 'ne' ? 'विवरण र सरकारी प्रमाण-पत्र थप्नुहोस्' : 'Verification & Operational Identity'}
                  </p>
                </div>
              </div>

              {/* Form container */}
              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  if (!empSetupName.trim()) {
                    alert(lang === 'ne' ? 'कृपया आफ्नो नाम लेख्नुहोस्।' : 'Please enter your full name.');
                    return;
                  }
                  if (!empSetupGovIdNum.trim()) {
                    alert(lang === 'ne' ? 'कृपया सरकारी परिचय-पत्र नम्बर हाल्नुहोस्।' : 'Please enter your Government ID number.');
                    return;
                  }
                  handleCreateEmployerProfile({
                    name: empSetupName,
                    companyName: empSetupCompany || 'Individual',
                    phone: phone,
                    location: empSetupLocation,
                    role: empSetupRole,
                    govId: `${empSetupGovIdType.toUpperCase()} - ${empSetupGovIdNum}`,
                    profilePhoto: empSetupPhoto || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80',
                    isVerified: true
                  });
                }}
                className="space-y-3.5 pt-1"
              >
                {/* Profile Photo Selector / Upload */}
                <div className="bg-white p-3.5 rounded-2xl border border-slate-150 shadow-sm flex flex-col items-center text-center space-y-2">
                  <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                    {lang === 'ne' ? 'प्रोफाइल फोटो' : 'Profile Photo'}
                  </label>
                  
                  <div className="relative">
                    <img
                      src={empSetupPhoto || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80'}
                      alt="Profile preview"
                      referrerPolicy="no-referrer"
                      className="w-16 h-16 rounded-full border-2 border-indigo-500 object-cover bg-slate-100 shadow-sm"
                    />
                    <div className="absolute -bottom-1 -right-1 bg-indigo-600 text-white p-1 rounded-full border border-white shadow-sm">
                      <Plus className="h-3.5 w-3.5" />
                    </div>
                  </div>

                  {/* Preset quick avatars or file uploader */}
                  <div className="space-y-1 w-full">
                    <p className="text-[9px] text-slate-400 font-bold">
                      {lang === 'ne' ? 'फोटो छान्नुहोस् वा फाइल राख्नुहोस्:' : 'Select a preset or upload:'}
                    </p>
                    <div className="flex gap-2 justify-center">
                      {[
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80',
                        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=150&h=150&q=80',
                        'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=150&h=150&q=80'
                      ].map((imgUrl, idx) => (
                        <button
                          key={idx}
                          type="button"
                          onClick={() => setEmpSetupPhoto(imgUrl)}
                          className={`w-9 h-9 rounded-full overflow-hidden border-2 transition-all ${
                            empSetupPhoto === imgUrl ? 'border-indigo-600 scale-105' : 'border-transparent hover:border-slate-300'
                          }`}
                        >
                          <img src={imgUrl} alt={`Avatar preset ${idx}`} className="w-full h-full object-cover" referrerPolicy="no-referrer" />
                        </button>
                      ))}
                    </div>
                    {/* Simulated manual upload button */}
                    <div className="pt-1">
                      <label className="inline-block px-3 py-1 bg-slate-50 border border-slate-200 text-[10px] text-slate-600 font-bold rounded-lg cursor-pointer hover:bg-slate-100 transition-colors">
                        <span>{lang === 'ne' ? 'आफ्नो फोटो राख्नुहोस्' : 'Upload custom photo'}</span>
                        <input
                          type="file"
                          accept="image/*"
                          className="hidden"
                          onChange={(e) => {
                            const file = e.target.files?.[0];
                            if (file) {
                              setEmpSetupPhoto(URL.createObjectURL(file));
                            }
                          }}
                        />
                      </label>
                    </div>
                  </div>
                </div>

                {/* Form fields */}
                <div className="space-y-2.5">
                  {/* Name field */}
                  <div className="space-y-0.5">
                    <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                      {lang === 'ne' ? 'रोजगारदाता / ठेकेदारको पूरा नाम' : 'Employer / Contractor Full Name'}
                    </label>
                    <input
                      type="text"
                      required
                      value={empSetupName}
                      onChange={(e) => setEmpSetupName(e.target.value)}
                      placeholder="e.g. Ajay Gupta"
                      className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-indigo-600 shadow-sm"
                    />
                  </div>

                  {/* Phone field (Pre-filled and read-only) */}
                  <div className="space-y-0.5">
                    <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                      {lang === 'ne' ? 'प्रमाणित मोबाइल नम्बर' : 'Verified Phone Number'}
                    </label>
                    <div className="relative">
                      <input
                        type="tel"
                        disabled
                        value={`+977 ${phone || '9851044321'}`}
                        className="w-full bg-slate-100 px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-500 shadow-inner"
                      />
                      <span className="absolute right-3.5 top-1/2 -translate-y-1/2 bg-emerald-500/10 text-emerald-600 font-black text-[9px] px-2 py-0.5 rounded border border-emerald-500/20">
                        VERIFIED
                      </span>
                    </div>
                  </div>

                  {/* Role and Location Row */}
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-0.5">
                      <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                        {lang === 'ne' ? 'भूमिका' : 'Role / Title'}
                      </label>
                      <select
                        value={empSetupRole}
                        onChange={(e) => setEmpSetupRole(e.target.value)}
                        className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-indigo-600 shadow-sm"
                      >
                        <option value="Contractor">{lang === 'ne' ? 'ठेकेदार (Contractor)' : 'Contractor'}</option>
                        <option value="Sub-contractor">{lang === 'ne' ? 'सहायक ठेकेदार' : 'Sub-contractor'}</option>
                        <option value="Home Owner">{lang === 'ne' ? 'घरधनी / व्यक्तिगत' : 'Home Owner / Builder'}</option>
                        <option value="Business Owner">{lang === 'ne' ? 'व्यवसाय मालिक' : 'Business Owner'}</option>
                      </select>
                    </div>

                    <div className="space-y-0.5">
                      <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                        {lang === 'ne' ? 'स्थान' : 'Primary Location'}
                      </label>
                      <select
                        value={empSetupLocation}
                        onChange={(e) => setEmpSetupLocation(e.target.value)}
                        className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-indigo-600 shadow-sm"
                      >
                        {NEPAL_LOCATIONS.map(loc => (
                          <option key={loc} value={loc}>{loc}</option>
                        ))}
                      </select>
                    </div>
                  </div>

                  {/* Company Name (Optional) */}
                  <div className="space-y-0.5">
                    <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                      {lang === 'ne' ? 'कम्पनी / फर्मको नाम (ऐच्छिक)' : 'Company Name (Optional)'}
                    </label>
                    <input
                      type="text"
                      value={empSetupCompany}
                      onChange={(e) => setEmpSetupCompany(e.target.value)}
                      placeholder="e.g. Gupta Construction"
                      className="w-full bg-white px-3 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-indigo-600 shadow-sm"
                    />
                  </div>

                  {/* Government Verification ID Section */}
                  <div className="bg-slate-100/80 p-3.5 rounded-2xl border border-slate-200 space-y-2.5">
                    <div className="flex justify-between items-center">
                      <label className="text-[10px] font-extrabold text-indigo-950 uppercase tracking-wider block">
                        🛡️ {lang === 'ne' ? 'सरकारी परिचय-पत्र (सत्यापन)' : 'Government ID Verification'}
                      </label>
                      <span className="text-[8px] bg-indigo-600/10 text-indigo-700 px-2 py-0.5 rounded font-black">COMPULSORY</span>
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <select
                        value={empSetupGovIdType}
                        onChange={(e) => setEmpSetupGovIdType(e.target.value)}
                        className="bg-white px-2.5 py-2 rounded-xl border border-slate-200 text-[11px] font-bold focus:outline-none focus:border-indigo-600"
                      >
                        <option value="citizenship">{lang === 'ne' ? 'नागरिकता प्रमाण-पत्र' : 'Citizenship Card'}</option>
                        <option value="license">{lang === 'ne' ? 'सवारी चालक अनुमति' : 'Driving License'}</option>
                        <option value="pan">{lang === 'ne' ? 'प्यान/भ्याट (PAN Card)' : 'PAN / VAT Card'}</option>
                        <option value="registration">{lang === 'ne' ? 'कम्पनी दर्ता प्रमाण' : 'Business Registry'}</option>
                      </select>

                      <input
                        type="text"
                        required
                        value={empSetupGovIdNum}
                        onChange={(e) => setEmpSetupGovIdNum(e.target.value)}
                        placeholder={lang === 'ne' ? 'आईडी नम्बर' : 'ID Number (e.g., 55-01-78)'}
                        className="bg-white px-3 py-2 rounded-xl border border-slate-200 text-[11px] font-bold focus:outline-none focus:border-indigo-600"
                      />
                    </div>

                    {/* Simulated Document Upload Box */}
                    <div className="bg-white border-2 border-dashed border-slate-300 rounded-xl p-3 flex flex-col items-center text-center cursor-pointer hover:border-indigo-500 transition-colors relative">
                      <input
                        type="file"
                        accept="image/*,application/pdf"
                        className="absolute inset-0 opacity-0 cursor-pointer"
                        onChange={(e) => {
                          const file = e.target.files?.[0];
                          if (file) {
                            setEmpSetupGovIdFile(file.name);
                          }
                        }}
                      />
                      <ClipboardList className="h-5 w-5 text-slate-400 mb-1" />
                      {empSetupGovIdFile ? (
                        <p className="text-[10px] text-indigo-600 font-extrabold flex items-center gap-1">
                          <Check className="h-3 w-3 text-emerald-500" />
                          <span>{empSetupGovIdFile}</span>
                        </p>
                      ) : (
                        <div className="space-y-0.5">
                          <p className="text-[10px] text-slate-700 font-bold">
                            {lang === 'ne' ? 'परिचय-पत्रको फोटो खिच्नुहोस् / अपलोड' : 'Snap photo / drag-drop doc'}
                          </p>
                          <p className="text-[8px] text-slate-400 font-bold">PNG, JPG, PDF up to 4MB</p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Submit button */}
                <button
                  type="submit"
                  className="w-full py-3.5 mt-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-white font-extrabold text-xs shadow-md transition-colors flex items-center justify-center gap-1.5 active:scale-95 border-b-4 border-slate-950"
                >
                  <CheckCircle className="h-4 w-4 text-emerald-400" />
                  <span>{lang === 'ne' ? 'सुरक्षित गर्नुहोस्' : 'Verify ID & Start Hiring'}</span>
                </button>
              </form>
            </div>

            <p className="text-[9px] text-center text-slate-400 font-bold mt-4">
              ROJGAR VERIFIED RECRUITMENT • GOVT OF NEPAL COMPLIANCE
            </p>
          </div>
        )}

        {/* ==================== SCREEN: WORKER HOME ==================== */}
        {screen === 'worker_home' && (
          <div className="flex-1 flex flex-col bg-slate-50 h-full justify-between" id="worker_home_screen">
            {/* Main scrollable body */}
            <div className="flex-1 flex flex-col overflow-y-auto overflow-x-hidden">
              
              {/* === TAB: JOBS / FIND === */}
              {workerTab === 'jobs' && (
                <div className="flex-1 flex flex-col h-full animate-fadeIn">
                  {/* Header */}
                  <div className="bg-slate-900 text-white px-4 py-3 flex items-center justify-between shadow sticky top-0 z-10">
                    <div className="space-y-0.5">
                      <h1 className="text-sm font-bold text-emerald-400 flex items-center gap-1">
                        <Briefcase className="h-4 w-4" />
                        <span>{lang === 'ne' ? 'काम खोज्नुहोस्' : 'Find Jobs'}</span>
                      </h1>
                      <p className="text-[10px] text-slate-300">Lalitpur / Kathmandu</p>
                    </div>
                    <button
                      onClick={() => {
                        setRole('employer');
                        setScreen('employer_home');
                      }}
                      className="text-[10px] font-bold bg-white/10 hover:bg-white/20 text-white px-2.5 py-1.5 rounded-lg border border-white/20"
                    >
                      {lang === 'ne' ? 'रोजगारदाता मोड' : 'Employer Mode'}
                    </button>
                  </div>

                  {/* Search Input and view toggle bar */}
                  <div className="p-3 bg-slate-900/95 text-white flex items-center gap-2">
                    <div className="flex-1 bg-white rounded-lg flex items-center px-2.5 shadow-inner">
                      <Search className="h-4 w-4 text-slate-400" />
                      <input
                        type="text"
                        placeholder={lang === 'ne' ? 'काम खोज्नुहोस्...' : 'Search jobs...'}
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full bg-transparent border-none text-slate-800 text-xs font-medium py-2 px-2 focus:outline-none"
                      />
                    </div>
                    <button
                      onClick={() => setIsMapView(!isMapView)}
                      className="p-2 rounded-lg bg-emerald-500 hover:bg-emerald-600 text-white transition-all transform active:scale-95"
                      title={isMapView ? "List View" : "Map View"}
                    >
                      {isMapView ? <List className="h-4 w-4" /> : <Map className="h-4 w-4" />}
                    </button>
                  </div>

                  {/* Icon-Based Category Selector (Page 16 of proposal: "Icon-based navigation") */}
                  <div className="bg-white border-b border-slate-100 py-2.5 px-3 flex gap-2 overflow-x-auto select-none no-scrollbar">
                    <button
                      onClick={() => setSelectedCategory('all')}
                      className={`px-3 py-1.5 rounded-full text-[11px] font-bold shrink-0 transition-colors ${
                        selectedCategory === 'all'
                          ? 'bg-slate-900 text-white'
                          : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                      }`}
                    >
                      {lang === 'ne' ? 'सबै काम' : 'All'}
                    </button>
                    {SKILL_CATEGORIES.map(cat => (
                      <button
                        key={cat.id}
                        onClick={() => setSelectedCategory(cat.id)}
                        className={`px-3 py-1.5 rounded-full text-[11px] font-bold shrink-0 flex items-center gap-1 transition-colors ${
                          selectedCategory === cat.id
                            ? 'bg-slate-900 text-white'
                            : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                        }`}
                      >
                        {getCatIcon(cat.id)}
                        <span>{lang === 'ne' ? cat.nameNe.split(' ')[0] : cat.nameEn.split(' ')[0]}</span>
                      </button>
                    ))}
                  </div>

                  {/* List and Map Content block */}
                  <div className="flex-1 overflow-y-auto p-4 space-y-3">
                    {isMapView ? (
                      /* MAP VIEW SIMULATION */
                      <div className="bg-slate-200 h-80 rounded-2xl border border-slate-300 relative overflow-hidden flex flex-col justify-between p-3 shadow-inner">
                        <div className="absolute inset-0 opacity-20 bg-[radial-gradient(#000_1px,transparent_1px)] [background-size:16px_16px]" />
                        <div className="bg-white/90 backdrop-blur-sm p-2 rounded-lg text-[10px] text-slate-500 font-bold self-start border border-slate-200">
                          📍 {lang === 'ne' ? 'नक्सामा नजिकैका कामहरू' : 'Nearby Jobs on Map'}
                        </div>

                        {/* Dynamic Pins */}
                        <div className="absolute left-[80px] top-[100px] animate-bounce">
                          <button 
                            onClick={() => setActiveJobDetails(jobs[0])}
                            className="bg-slate-900 text-white text-[10px] font-bold py-1 px-2 rounded-full border-2 border-emerald-500 shadow-md flex items-center gap-0.5"
                          >
                            <MapPin className="h-3 w-3 text-emerald-400" />
                            <span>Rs. {jobs[0]?.wage}</span>
                          </button>
                        </div>

                        <div className="absolute right-[90px] bottom-[110px] animate-bounce">
                          <button 
                            onClick={() => setActiveJobDetails(jobs[1])}
                            className="bg-slate-900 text-white text-[10px] font-bold py-1 px-2 rounded-full border-2 border-emerald-500 shadow-md flex items-center gap-0.5"
                          >
                            <MapPin className="h-3 w-3 text-emerald-400" />
                            <span>Rs. {jobs[1]?.wage}</span>
                          </button>
                        </div>

                        <p className="text-[10px] text-center text-slate-500 italic mt-auto z-10">
                          {lang === 'ne' ? 'नक्साको पिनमा थिचेर जागिरको विवरण हेर्नुहोस्' : 'Tap on the map pins to view job details'}
                        </p>
                      </div>
                    ) : (
                      /* JOB LIST FEED */
                      <>
                        {filteredJobs.length === 0 ? (
                          <div className="text-center py-10 space-y-2">
                            <AlertCircle className="h-8 w-8 text-slate-300 mx-auto" />
                            <p className="text-xs text-slate-400">{lang === 'ne' ? 'कुनै पनि काम भेटिएन।' : 'No jobs matches your filters.'}</p>
                          </div>
                        ) : (
                          filteredJobs.map(job => {
                            const isApplied = applications.some(app => app.jobId === job.id);
                            const myApp = applications.find(app => app.jobId === job.id);
                            
                            return (
                              <div key={job.id} className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex flex-col gap-3 relative overflow-hidden">
                                {/* Top row */}
                                <div className="flex justify-between items-start gap-2">
                                  <div>
                                    <h2 className="text-xs font-black text-slate-900 tracking-tight leading-tight">{job.title}</h2>
                                    <p className="text-[10px] text-slate-500 flex items-center gap-0.5 mt-0.5">
                                      <MapPin className="h-3 w-3 text-slate-400" />
                                      <span>{job.location}</span>
                                    </p>
                                  </div>
                                  <span className="shrink-0 text-xs font-bold text-emerald-500 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full">
                                    Rs. {job.wage}/d
                                  </span>
                                </div>

                                {/* Description summary */}
                                <p className="text-[11px] text-slate-500 leading-relaxed line-clamp-2">
                                  {job.description}
                                </p>

                                {/* Action buttons */}
                                <div className="flex items-center gap-2 pt-1 border-t border-slate-100/50">
                                  <button
                                    onClick={() => setActiveJobDetails(job)}
                                    className="flex-1 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-[11px] font-bold text-center transition-colors"
                                  >
                                    {lang === 'ne' ? 'विवरण हेर्नुहोस्' : 'View Details'}
                                  </button>

                                  {isApplied ? (
                                    <span className={`px-2 py-2 rounded-xl text-[10px] font-extrabold text-center flex items-center justify-center gap-1 flex-1 ${
                                      myApp?.status === 'accepted' 
                                        ? 'bg-emerald-500/10 text-emerald-600' 
                                        : myApp?.status === 'rejected' 
                                          ? 'bg-red-500/10 text-red-500' 
                                          : 'bg-slate-100 text-slate-500'
                                    }`}>
                                      <CheckCircle className="h-3.5 w-3.5" />
                                      <span>{myApp?.status === 'accepted' ? (lang === 'ne' ? 'स्वीकृत' : 'ACCEPTED') : myApp?.status === 'rejected' ? (lang === 'ne' ? 'अस्वीकृत' : 'DECLINED') : (lang === 'ne' ? 'अपेक्षित' : 'PENDING')}</span>
                                    </span>
                                  ) : (
                                    <button
                                      onClick={() => handleApplyForJob(job.id)}
                                      className="flex-1 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white text-[11px] font-bold text-center transition-colors transform active:scale-95"
                                    >
                                      {lang === 'ne' ? 'आवेदन दिनुहोस्' : 'One-Tap Apply'}
                                    </button>
                                  )}
                                </div>
                              </div>
                            );
                          })
                        )}
                      </>
                    )}
                  </div>
                </div>
              )}

              {/* === TAB: APPLICATIONS === */}
              {workerTab === 'applications' && (
                <div className="flex-1 p-4 space-y-3 animate-fadeIn">
                  <h3 className="text-sm font-black text-slate-900 uppercase tracking-tight mb-2">{lang === 'ne' ? 'मेरा आवेदनहरू' : 'Your Job Applications'}</h3>
                  {applications.filter(app => {
                    const activeWorker = workers.find(w => w.phone === phone) || workers[0];
                    return app.workerId === activeWorker?.id;
                  }).length === 0 ? (
                    <div className="text-center py-10 bg-white border border-slate-100 rounded-2xl text-slate-400 text-xs">No submitted applications yet. Use one-tap apply!</div>
                  ) : (
                    applications.filter(app => {
                      const activeWorker = workers.find(w => w.phone === phone) || workers[0];
                      return app.workerId === activeWorker?.id;
                    }).map((app) => {
                      const associatedJob = jobs.find(j => j.id === app.jobId);
                      return (
                        <div key={app.id} className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex flex-col gap-3">
                          <div className="flex justify-between items-start">
                            <div>
                              <h4 className="text-xs font-black text-slate-900 leading-tight">{associatedJob?.title || 'Unknown Job'}</h4>
                              <p className="text-[10px] text-slate-500 mt-0.5">Employer: <strong className="text-slate-700">{associatedJob?.employerName}</strong></p>
                            </div>
                            <span className={`text-[9px] px-2 py-0.5 rounded-full font-bold border ${
                              app.status === 'accepted' 
                                ? 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20' 
                                : app.status === 'rejected' 
                                  ? 'bg-red-500/10 text-red-500 border-red-500/20' 
                                  : 'bg-slate-100 text-slate-500 border-slate-200'
                            }`}>
                              {app.status.toUpperCase()}
                            </span>
                          </div>

                          <div className="grid grid-cols-2 gap-2 text-[10px] py-1 border-t border-b border-slate-100 bg-slate-50/50 p-2 rounded-lg">
                            <div>
                              <span className="text-slate-400 block uppercase font-bold text-[8px]">Location</span>
                              <span className="font-extrabold text-slate-700">{associatedJob?.location || 'Nepal'}</span>
                            </div>
                            <div>
                              <span className="text-slate-400 block uppercase font-bold text-[8px]">Offered Wage</span>
                              <span className="font-extrabold text-emerald-600">Rs. {associatedJob?.wage || '1200'}/day</span>
                            </div>
                          </div>

                          {/* Direct Action */}
                          {app.status === 'accepted' && (
                            <button
                              onClick={() => {
                                setCallingPhone(associatedJob?.employerPhone || '9851044321');
                                setCallingName(associatedJob?.employerName || 'Contractor');
                              }}
                              className="w-full py-2 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white font-bold text-[11px] flex items-center justify-center gap-1 animate-pulse"
                            >
                              <Phone className="h-3.5 w-3.5" />
                              <span>{lang === 'ne' ? 'रोजगारदातालाई कल गर्नुहोस्' : 'Call Employer Now'}</span>
                            </button>
                          )}
                        </div>
                      );
                    })
                  )}
                </div>
              )}

              {/* === TAB: CHAT === */}
              {workerTab === 'chat' && (
                <div className="flex-1 flex flex-col h-full bg-slate-50 animate-fadeIn">
                  {activeChatChannel ? (
                    /* Active Chat conversation */
                    <div className="flex-1 flex flex-col h-full bg-slate-100">
                      {/* Chat Header */}
                      <div className="bg-slate-900 text-white p-3 flex items-center justify-between sticky top-0 z-10">
                        <button onClick={() => setActiveChatChannel(null)} className="flex items-center gap-1 text-xs text-slate-300 font-bold hover:text-white">
                          <ArrowLeft className="h-4 w-4" />
                          <span>{lang === 'ne' ? 'फिर्ता' : 'Back'}</span>
                        </button>
                        <span className="font-extrabold text-xs">{activeChatChannel}</span>
                        <div className="w-5 h-5 rounded-full bg-emerald-500 flex items-center justify-center">
                          <div className="w-2.5 h-2.5 rounded-full bg-white animate-ping" />
                        </div>
                      </div>

                      {/* Messages scroll content */}
                      <div className="flex-1 overflow-y-auto p-4 space-y-3">
                        {(chatMessages[activeChatChannel] || []).map((msg, idx) => (
                          <div key={idx} className={`flex flex-col max-w-[80%] ${msg.sender === 'user' ? 'ml-auto items-end' : 'mr-auto items-start'}`}>
                            <div className={`p-3 rounded-2xl text-xs font-semibold leading-relaxed ${
                              msg.sender === 'user' ? 'bg-indigo-600 text-white rounded-br-none shadow-md shadow-indigo-600/10' : 'bg-white text-slate-800 rounded-bl-none border border-slate-200'
                            }`}>
                              {msg.text}
                            </div>
                            <span className="text-[9px] text-slate-400 mt-1 px-1 font-bold">{msg.time}</span>
                          </div>
                        ))}
                      </div>

                      {/* Presets suggestions */}
                      <div className="bg-white/80 backdrop-blur-sm p-2 border-t border-slate-200 flex gap-1.5 overflow-x-auto no-scrollbar">
                        {[
                          lang === 'ne' ? 'म काम गर्न तयार छु।' : 'I am ready for the work.',
                          lang === 'ne' ? 'स्थान कहाँ हो?' : 'Where is the exact location?',
                          lang === 'ne' ? 'म भोलि बिहान आउनेछु।' : 'I will arrive tomorrow morning.'
                        ].map((preset, pIdx) => (
                          <button
                            key={pIdx}
                            onClick={() => {
                              setNewMsgText(preset);
                            }}
                            className="bg-slate-100 hover:bg-slate-200 text-slate-700 text-[10px] font-bold px-3 py-1.5 rounded-full shrink-0 border border-slate-200 transition-colors"
                          >
                            {preset}
                          </button>
                        ))}
                      </div>

                      {/* Chat Input row */}
                      <div className="bg-white p-3 border-t border-slate-200 flex items-center gap-2">
                        <input
                          type="text"
                          value={newMsgText}
                          onChange={(e) => setNewMsgText(e.target.value)}
                          onKeyDown={(e) => e.key === 'Enter' && handleSendChatMessage(activeChatChannel)}
                          placeholder={lang === 'ne' ? 'सन्देश लेख्नुहोस्...' : 'Type message...'}
                          className="flex-1 bg-slate-50 px-4 py-2.5 rounded-full border border-slate-200 text-xs focus:outline-none focus:border-indigo-500 font-semibold shadow-inner"
                        />
                        <button
                          onClick={() => handleSendChatMessage(activeChatChannel)}
                          className="bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-black px-4 py-2.5 rounded-full shadow transition-all transform active:scale-95 shrink-0"
                        >
                          {lang === 'ne' ? 'पठाउनुहोस्' : 'Send'}
                        </button>
                      </div>
                    </div>
                  ) : (
                    /* Chats directory channels */
                    <div className="flex-1 p-4 space-y-3">
                      <h2 className="text-sm font-black text-slate-900 uppercase tracking-tight">{lang === 'ne' ? 'मेरो च्याटहरू' : 'Your Chat Inbox'}</h2>
                      {['Ravi Ranjan Sah', 'Ajay Kumar Sah'].map((user) => {
                        const lastMsg = chatMessages[user]?.[chatMessages[user].length - 1];
                        return (
                          <button
                            key={user}
                            onClick={() => setActiveChatChannel(user)}
                            className="w-full bg-white p-3.5 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-3.5 hover:border-slate-300 transition-all text-left"
                          >
                            <div className="w-10 h-10 rounded-full bg-indigo-500/10 text-indigo-600 flex items-center justify-center font-black text-sm border border-indigo-500/20 shrink-0">
                              {user.charAt(0)}
                            </div>
                            <div className="flex-1 min-w-0">
                              <div className="flex justify-between items-center">
                                <span className="text-xs font-extrabold text-slate-900">{user}</span>
                                <span className="text-[9px] text-slate-400 font-bold">{lastMsg?.time || 'Now'}</span>
                              </div>
                              <p className="text-[10px] text-slate-500 truncate mt-0.5">{lastMsg?.text || 'No messages yet.'}</p>
                            </div>
                          </button>
                        );
                      })}
                    </div>
                  )}
                </div>
              )}

              {/* === TAB: SYNC === */}
              {workerTab === 'sync' && (
                <div className="flex-1 p-5 space-y-4 animate-fadeIn flex flex-col justify-between">
                  <div className="space-y-4">
                    <h2 className="text-sm font-black text-slate-900 uppercase tracking-tight flex items-center gap-1.5">
                      <RefreshCw className="h-4.5 w-4.5 text-indigo-500" />
                      <span>{lang === 'ne' ? 'सिंक र अफलाइन प्रणाली' : 'Sync HUD Manager'}</span>
                    </h2>

                    {/* Network connectivity toggle simulation */}
                    <div className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
                      <div className="space-y-1">
                        <span className="text-xs font-extrabold text-slate-900">{lang === 'ne' ? 'इन्टरनेट जडान' : 'Internet Connection'}</span>
                        <p className="text-[10px] text-slate-400">{lang === 'ne' ? 'वाइफाइ वा मोबाइल डाटा' : 'Toggle WiFi/Mobile Data'}</p>
                      </div>
                      <button
                        onClick={() => setIsOnline(!isOnline)}
                        className={`px-4 py-2 rounded-xl text-xs font-extrabold border transition-all ${
                          isOnline 
                            ? 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20' 
                            : 'bg-red-500/10 text-red-500 border-red-500/20'
                        }`}
                      >
                        {isOnline ? (lang === 'ne' ? 'अनलाइन' : 'ONLINE') : (lang === 'ne' ? 'अफलाइन' : 'OFFLINE')}
                      </button>
                    </div>

                    {/* Sync actions card */}
                    <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4 text-center">
                      <div className="mx-auto w-20 h-20 rounded-full bg-indigo-50 flex items-center justify-center relative">
                        {isSyncing ? (
                          <Loader2 className="h-10 w-10 text-indigo-600 animate-spin" />
                        ) : (
                          <RefreshCw className="h-8 w-8 text-indigo-600" />
                        )}
                        {isSyncing && (
                          <span className="absolute inset-0 rounded-full border-4 border-indigo-600 border-t-transparent animate-spin" />
                        )}
                      </div>

                      <div className="space-y-1">
                        <span className="text-xs font-extrabold text-slate-900">{lang === 'ne' ? 'डाटाबेस सिंक्रोनाइजेसन' : 'Offline Database Sync'}</span>
                        <p className="text-[10px] text-slate-400 leading-relaxed max-w-xs mx-auto">
                          {lang === 'ne' 
                            ? 'मोबाइल डाटा महँगो हुन्छ। नेपालको जुनसुकै स्थानमा काम खोज्न पहिले नै सबै विज्ञापनहरू फोनमा सिंक गर्नुहोस्।' 
                            : 'Wages and listings are downloaded locally. Find labor opportunities without burning mobile data balances at site.'}
                        </p>
                      </div>

                      {isSyncing ? (
                        <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                          <div className="bg-indigo-600 h-full transition-all duration-150" style={{ width: `${syncProgress}%` }} />
                        </div>
                      ) : (
                        <button
                          onClick={handleSyncDatabase}
                          className="w-full py-3.5 rounded-xl bg-slate-900 text-white text-xs font-black hover:bg-slate-800 transition-colors active:scale-95"
                        >
                          {lang === 'ne' ? 'अहिले नै सिंक गर्नुहोस्' : 'SYNCHRONIZE OFFLINE DATABASE'}
                        </button>
                      )}

                      <div className="text-[10px] text-slate-400 font-bold flex justify-between px-1">
                        <span>Last sync: {lastSyncTime}</span>
                        <span>Cache: {jobs.length} jobs stored</span>
                      </div>
                    </div>
                  </div>

                  <p className="text-[9px] text-center text-slate-400 font-bold">
                    ROJGAR Nepalese Labor Platform • Version 1.0.2 Offline HUD
                  </p>
                </div>
              )}

              {/* === TAB: PROFILE === */}
              {workerTab === 'profile' && (
                <div className="flex-1 p-4 space-y-4 animate-fadeIn">
                  {/* Top brand header */}
                  <div className="flex items-center justify-between py-1 bg-transparent">
                    <div className="flex items-center gap-3">
                      {/* Circle green logo with diamond design */}
                      <div className="w-11 h-11 rounded-full bg-emerald-600 flex items-center justify-center shadow shadow-emerald-800/20 shrink-0">
                        <div className="w-5 h-5 border-2 border-white rotate-45 flex items-center justify-center">
                          <div className="w-2 h-2 bg-white rounded-full" />
                        </div>
                      </div>
                      <div className="space-y-0.5">
                        <h2 className="text-base font-black text-slate-900 tracking-tight leading-none">ROJGAR WORKER</h2>
                        <p className="text-[10px] font-bold text-slate-500">कामदार पोर्टल • Nepal</p>
                      </div>
                    </div>

                    {/* Online indicator badge */}
                    <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-emerald-550/10 border border-emerald-100 text-emerald-600 font-extrabold text-[11px] tracking-tight">
                      <span className="h-2 w-2 rounded-full bg-emerald-500 inline-block animate-pulse" />
                      <span>ONLINE</span>
                    </span>
                  </div>

                  {/* Dynamic Active Profile Card */}
                  {(() => {
                    const activeWorker = workers.find(w => w.phone === phone) || workers[0] || {
                      name: 'Ram Bahadur',
                      phone: phone || '9845551122',
                      mainSkill: 'laborer',
                      experience: '2 Years',
                      expectedWage: 1200,
                      location: 'Balkumari, Lalitpur',
                      bio: 'Construction site bricklayer and manual helper.'
                    };

                    if (isEditingProfile) {
                      return (
                        <div className="space-y-4 animate-fadeIn bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
                          <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
                            <button
                              type="button"
                              onClick={() => setIsEditingProfile(false)}
                              className="p-1 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-full transition-colors"
                            >
                              <ArrowLeft className="h-4.5 w-4.5" />
                            </button>
                            <div>
                              <h3 className="text-xs font-black text-slate-900 tracking-tight uppercase">
                                {lang === 'ne' ? 'प्रोफाइल सम्पादन' : 'Edit Profile Info'}
                              </h3>
                              <p className="text-[9px] text-slate-400 font-bold uppercase">
                                {lang === 'ne' ? 'विवरण परिमार्जन गर्नुहोस्' : 'Update your worker details'}
                              </p>
                            </div>
                          </div>

                          {/* Profile Photo selector */}
                          <div className="space-y-2 flex flex-col items-center">
                            <label className="text-[9px] font-extrabold text-slate-400 uppercase tracking-wider block">
                              {lang === 'ne' ? 'प्रोफाइल फोटो' : 'Profile Photo'}
                            </label>
                            {editWorkerPhoto ? (
                              <img
                                src={editWorkerPhoto}
                                alt="Profile Preview"
                                referrerPolicy="no-referrer"
                                className="w-14 h-14 rounded-full border-2 border-emerald-500 object-cover bg-slate-50 shadow-sm"
                              />
                            ) : (
                              <div className="w-14 h-14 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-400 text-lg font-black">
                                {editWorkerName ? editWorkerName.charAt(0).toUpperCase() : '?'}
                              </div>
                            )}
                            <label className="px-2 py-1 bg-slate-50 border border-slate-200 text-[9px] text-slate-600 font-bold rounded-lg cursor-pointer hover:bg-slate-100">
                              <span>{lang === 'ne' ? 'फोटो परिवर्तन गर्नुहोस्' : 'Upload photo'}</span>
                              <input
                                type="file"
                                accept="image/*"
                                className="hidden"
                                onChange={(e) => {
                                  const file = e.target.files?.[0];
                                  if (file) {
                                    setEditWorkerPhoto(URL.createObjectURL(file));
                                  }
                                }}
                              />
                            </label>
                          </div>

                          <div className="space-y-3 pt-1">
                            {/* Name */}
                            <div className="space-y-1">
                              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                {lang === 'ne' ? 'कामदारको नाम' : 'Full Name'}
                              </label>
                              <input
                                type="text"
                                value={editWorkerName}
                                onChange={(e) => setEditWorkerName(e.target.value)}
                                className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-emerald-500"
                              />
                            </div>

                            {/* Phone and Government Verification ID */}
                            <div className="grid grid-cols-2 gap-2.5">
                              <div className="space-y-1">
                                <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                  {lang === 'ne' ? 'सम्पर्क नम्बर' : 'Phone Number'}
                                </label>
                                <input
                                  type="text"
                                  value={editWorkerPhone}
                                  onChange={(e) => setEditWorkerPhone(e.target.value)}
                                  className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-emerald-500"
                                />
                              </div>

                              <div className="space-y-1">
                                <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                  {lang === 'ne' ? 'सरकारी परिचय-पत्र' : 'Government ID'}
                                </label>
                                <input
                                  type="text"
                                  value={editWorkerGovId}
                                  onChange={(e) => setEditWorkerGovId(e.target.value)}
                                  placeholder="e.g. 55-01-78-999"
                                  className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-emerald-500"
                                />
                              </div>
                            </div>

                            {/* Wage and Location */}
                            <div className="grid grid-cols-2 gap-2.5">
                              <div className="space-y-1">
                                <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                  {lang === 'ne' ? 'दैनिक ज्याला' : 'Daily Wage'}
                                </label>
                                <input
                                  type="number"
                                  value={editWorkerWage}
                                  onChange={(e) => setEditWorkerWage(e.target.value)}
                                  className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-emerald-500"
                                />
                              </div>

                              <div className="space-y-1">
                                <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                  {lang === 'ne' ? 'स्थान' : 'Location'}
                                </label>
                                <select
                                  value={editWorkerLocation}
                                  onChange={(e) => setEditWorkerLocation(e.target.value)}
                                  className="w-full bg-white px-2 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-emerald-500"
                                >
                                  {NEPAL_LOCATIONS.map(loc => (
                                    <option key={loc} value={loc}>{loc}</option>
                                  ))}
                                </select>
                              </div>
                            </div>

                            {/* Skill Selection */}
                            <div className="space-y-1">
                              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                {lang === 'ne' ? 'मुख्य सिप / भूमिका' : 'Primary Skill / Role'}
                              </label>
                              <select
                                value={editWorkerRole}
                                onChange={(e) => setEditWorkerRole(e.target.value)}
                                className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-emerald-500"
                              >
                                {SKILL_CATEGORIES.map(cat => (
                                  <option key={cat.id} value={cat.id}>
                                    {lang === 'ne' ? cat.nameNe : cat.nameEn}
                                  </option>
                                ))}
                              </select>
                            </div>

                            {/* Bio */}
                            <div className="space-y-1">
                              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                {lang === 'ne' ? 'जानकारी' : 'Short Bio'}
                              </label>
                              <textarea
                                value={editWorkerBio}
                                onChange={(e) => setEditWorkerBio(e.target.value)}
                                rows={2}
                                className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-emerald-500"
                              />
                            </div>

                            {/* Actions */}
                            <div className="flex gap-2 pt-2 border-t border-slate-100">
                              <button
                                type="button"
                                onClick={() => {
                                  setIsEditingProfile(false);
                                }}
                                className="flex-1 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs"
                              >
                                {lang === 'ne' ? 'रद्द' : 'Cancel'}
                              </button>
                              <button
                                type="button"
                                onClick={() => {
                                  if (!editWorkerName.trim()) {
                                    alert('Name is required');
                                    return;
                                  }
                                  handleUpdateWorkerProfile({
                                    name: editWorkerName,
                                    phone: editWorkerPhone || activeWorker.phone,
                                    expectedWage: parseInt(editWorkerWage) || activeWorker.expectedWage,
                                    location: editWorkerLocation,
                                    mainSkill: editWorkerRole,
                                    bio: editWorkerBio,
                                    govId: editWorkerGovId,
                                    profilePhoto: editWorkerPhoto || activeWorker.profilePhoto
                                  });
                                }}
                                className="flex-1 py-2.5 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white font-extrabold text-xs"
                              >
                                {lang === 'ne' ? 'सुरक्षित गर्नुहोस्' : 'Save'}
                              </button>
                            </div>
                          </div>
                        </div>
                      );
                    }

                    return (
                      <div className="space-y-4">
                        {/* Profile Info Summary Card */}
                        <div className="bg-white border border-slate-200/60 rounded-2xl p-4 shadow-sm space-y-4">
                          <div className="flex items-center gap-3">
                            {activeWorker.profilePhoto ? (
                              <img
                                src={activeWorker.profilePhoto}
                                alt={activeWorker.name}
                                referrerPolicy="no-referrer"
                                className="w-12 h-12 rounded-full object-cover border-2 border-emerald-500 shadow-sm shrink-0"
                              />
                            ) : (
                              <div className="w-12 h-12 rounded-full bg-emerald-500 text-white flex items-center justify-center font-black text-lg shadow-sm shrink-0 uppercase">
                                {activeWorker.name.charAt(0)}
                              </div>
                            )}
                            <div className="space-y-0.5 min-w-0 flex-1">
                              <div className="flex items-center gap-1 flex-wrap">
                                <h4 className="text-sm font-black text-slate-950 truncate">{activeWorker.name}</h4>
                                <span className="text-[9px] bg-emerald-500/15 text-emerald-700 font-extrabold px-1.5 py-0.5 rounded flex items-center gap-0.5 shrink-0">
                                  <Check className="h-2.5 w-2.5 text-emerald-600 stroke-[3]" />
                                  <span>VERIFIED</span>
                                </span>
                              </div>
                              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                                {activeWorker.mainSkill.toUpperCase()} • {activeWorker.experience || '2 Years'} Exp
                              </p>
                            </div>
                          </div>

                          <div className="border-t border-slate-100 pt-3.5 space-y-2">
                            <div className="flex justify-between items-center text-xs">
                              <span className="font-bold text-slate-400">{lang === 'ne' ? 'मोबाइल नम्बर' : 'Phone Number'}</span>
                              <span className="font-extrabold text-slate-800">+977 {activeWorker.phone}</span>
                            </div>
                            <div className="flex justify-between items-center text-xs">
                              <span className="font-bold text-slate-400">{lang === 'ne' ? 'स्थान' : 'Location'}</span>
                              <span className="font-extrabold text-slate-800">{activeWorker.location}</span>
                            </div>
                            <div className="flex justify-between items-center text-xs">
                              <span className="font-bold text-slate-400">{lang === 'ne' ? 'सरकारी परिचय-पत्र' : 'Govt Verification ID'}</span>
                              {activeWorker.govId ? (
                                <span className="font-extrabold text-slate-800 flex items-center gap-1">
                                  <span>🛡️ {activeWorker.govId}</span>
                                </span>
                              ) : (
                                <span className="font-semibold text-amber-600 bg-amber-50 px-2 py-0.5 rounded border border-amber-100 text-[10px]">
                                  {lang === 'ne' ? 'सत्यापन आवश्यक' : 'Not Provided'}
                                </span>
                              )}
                            </div>
                            <div className="flex justify-between items-center text-xs">
                              <span className="font-bold text-slate-400">{lang === 'ne' ? 'दैनिक ज्याला' : 'Expected Daily Wage'}</span>
                              <span className="font-extrabold text-emerald-600 bg-emerald-50 px-2.5 py-0.5 rounded border border-emerald-100 text-[11px]">
                                Rs. {activeWorker.expectedWage} / Day
                              </span>
                            </div>
                            {activeWorker.bio && (
                              <div className="pt-2 border-t border-slate-50 text-[11px] text-slate-500 italic font-medium">
                                "{activeWorker.bio}"
                              </div>
                            )}
                          </div>

                          <button
                            onClick={() => {
                              setEditWorkerName(activeWorker.name);
                              setEditWorkerPhone(activeWorker.phone);
                              setEditWorkerWage(activeWorker.expectedWage.toString());
                              setEditWorkerRole(activeWorker.mainSkill);
                              setEditWorkerLocation(activeWorker.location);
                              setEditWorkerGovId(activeWorker.govId || '');
                              setEditWorkerPhoto(activeWorker.profilePhoto || '');
                              setEditWorkerBio(activeWorker.bio || '');
                              setIsEditingProfile(true);
                            }}
                            className="w-full py-2.5 bg-slate-50 hover:bg-slate-100 text-emerald-600 font-extrabold text-xs rounded-xl border border-slate-200 transition-colors flex items-center justify-center gap-1.5 active:scale-[0.98]"
                          >
                            <span>✏️</span>
                            <span>{lang === 'ne' ? 'प्रोफाइल विवरण परिमार्जन गर्नुहोस्' : 'Edit Profile Information'}</span>
                          </button>
                        </div>

                        {/* Profile section header */}
                        <h3 className="text-sm font-black text-slate-900 tracking-tight flex items-center gap-2 mt-2">
                          <span className="text-slate-500">⚙️</span>
                          <span>{lang === 'ne' ? 'प्रणाली सेटिंग्स र प्राथमिकताहरू' : 'Profile & System Settings'}</span>
                        </h3>

                        {/* System Settings & Customization Card */}
                        <div className="bg-white border border-slate-200/60 rounded-2xl p-4 shadow-sm space-y-4">
                          {/* Theme Preference selection */}
                          <div className="flex items-center justify-between border-b border-slate-50 pb-3">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'एपको थिम' : 'Application Theme'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'लाइट, डार्क वा सिस्टम थिम' : 'Light, Dark, or System theme'}
                              </span>
                            </div>
                            <div className="flex gap-1 bg-slate-50 p-1 rounded-xl border border-slate-200/60">
                              {[
                                { id: 'light', labelEn: 'Light', labelNe: 'लाइट' },
                                { id: 'dark', labelEn: 'Dark', labelNe: 'डार्क' },
                                { id: 'system', labelEn: 'System', labelNe: 'सिस्टम' }
                              ].map(t => (
                                <button
                                  key={t.id}
                                  onClick={() => setThemePref(t.id as any)}
                                  className={`px-2 py-1 rounded-lg text-[10px] font-black transition-all ${
                                    themePref === t.id ? 'bg-[#005bb5] text-white shadow-sm' : 'text-slate-500 hover:text-slate-800'
                                  }`}
                                >
                                  {lang === 'ne' ? t.labelNe : t.labelEn}
                                </button>
                              ))}
                            </div>
                          </div>

                          {/* Language Preference selection */}
                          <div className="flex items-center justify-between border-b border-slate-50 pb-3">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'एपको भाषा' : 'Application Language'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'एपको लागि भाषा चयन' : 'Change app interface language'}
                              </span>
                            </div>
                            <div className="flex gap-1.5 bg-slate-50 p-1 rounded-xl border border-slate-200/60">
                              <button
                                onClick={() => setLang('en')}
                                className={`px-2.5 py-1 rounded-lg text-[10px] font-black transition-all ${
                                  lang === 'en' ? 'bg-[#005bb5] text-white shadow-sm' : 'text-slate-500 hover:text-slate-800'
                                }`}
                              >
                                English
                              </button>
                              <button
                                onClick={() => setLang('ne')}
                                className={`px-2.5 py-1 rounded-lg text-[10px] font-black transition-all ${
                                  lang === 'ne' ? 'bg-[#005bb5] text-white shadow-sm' : 'text-slate-500 hover:text-slate-800'
                                }`}
                              >
                                नेपाली
                              </button>
                            </div>
                          </div>

                          {/* Voice Assistant Toggle */}
                          <div className="flex items-center justify-between border-b border-slate-50 pb-3">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'ध्वनि/आवाज सहायता' : 'Voice Assistance Synthesizer'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'बोलेर कामदार खोज्ने सहायता' : 'Speak-aloud voice prompts'}
                              </span>
                            </div>
                            <button
                              onClick={() => setVoiceFeedbackEnabled(!voiceFeedbackEnabled)}
                              className={`w-11 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${
                                voiceFeedbackEnabled ? 'bg-emerald-550 bg-emerald-500' : 'bg-slate-200'
                              }`}
                            >
                              <div
                                className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${
                                  voiceFeedbackEnabled ? 'translate-x-5' : 'translate-x-0'
                                }`}
                              />
                            </button>
                          </div>

                          {/* Sound alerts on match log Toggle */}
                          <div className="flex items-center justify-between">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'नयाँ कामदार मिलान सङ्केत' : 'Worker Match Audio Alerts'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'सङ्केत ध्वनीहरू प्ले गर्ने' : 'Sound alert on match discovery'}
                              </span>
                            </div>
                            <button
                              onClick={() => setSoundAlertsEnabled(!soundAlertsEnabled)}
                              className={`w-11 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${
                                soundAlertsEnabled ? 'bg-emerald-500' : 'bg-slate-200'
                              }`}
                            >
                              <div
                                className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${
                                  soundAlertsEnabled ? 'translate-x-5' : 'translate-x-0'
                                }`}
                              />
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })()}

                  {/* Logout Button */}
                  <button
                    onClick={() => {
                      setScreen('language_selection');
                      setPhone('');
                      setOtpSent(false);
                      setOtpCode('');
                      setRole(null);
                      setWorkerTab('jobs');
                      setEmployerTab('jobs');
                    }}
                    className="w-full py-3.5 bg-red-50 text-red-600 border border-red-200 hover:bg-red-100 font-black rounded-2xl text-[11px] tracking-wider transition-colors active:scale-[0.98] uppercase text-center flex items-center justify-center gap-1.5 mt-2"
                  >
                    <span>LOGOUT ACCOUNT (बाहिर निस्कनुहोस्)</span>
                  </button>
                </div>
              )}

            </div>

            {/* Worker Tab Navigation Bar */}
            <div className="h-16 bg-white border-t border-slate-100 flex items-center justify-around px-1 z-30 select-none shrink-0 shadow-lg shadow-slate-900/10">
              {[
                { id: 'jobs', label: lang === 'ne' ? 'कामहरू' : 'Jobs', icon: Briefcase },
                { id: 'applications', label: lang === 'ne' ? 'आवेदन' : 'Applications', icon: ClipboardList },
                { id: 'chat', label: lang === 'ne' ? 'च्याट' : 'Chat', icon: MessageSquare },
                { id: 'sync', label: lang === 'ne' ? 'सिंक HUD' : 'Sync HUD', icon: RefreshCw },
                { id: 'profile', label: lang === 'ne' ? 'प्रोफाइल' : 'Profile', icon: Settings }
              ].map((tab) => {
                const Icon = tab.icon;
                const isActive = workerTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    onClick={() => {
                      setWorkerTab(tab.id as any);
                      setActiveChatChannel(null);
                    }}
                    className="flex flex-col items-center justify-center flex-1 py-1 text-center"
                  >
                    <div className={`p-1 px-3 rounded-full transition-all ${
                      isActive ? 'bg-[#E8F0FE] text-[#005bb5]' : 'text-slate-400 hover:text-slate-600'
                    }`}>
                      <Icon className="h-5 w-5" />
                    </div>
                    <span className={`text-[9px] mt-1 font-bold ${
                      isActive ? 'text-slate-900 font-extrabold' : 'text-slate-500 font-semibold'
                    }`}>
                      {tab.label}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {/* ==================== SCREEN: EMPLOYER DASHBOARD ==================== */}
        {screen === 'employer_home' && (
          <div className="flex-1 flex flex-col bg-slate-50 h-full justify-between" id="employer_home_screen">
            {/* Main scrollable body */}
            <div className="flex-1 flex flex-col overflow-y-auto overflow-x-hidden">
              
              {/* === TAB: JOBS / DIRECTORY === */}
              {employerTab === 'jobs' && (
                <div className="flex-1 flex flex-col animate-fadeIn">
                  {/* Header */}
                  <div className="bg-slate-900 text-white px-4 py-3 flex items-center justify-between shadow sticky top-0 z-10">
                    <div className="space-y-0.5">
                      <h1 className="text-sm font-bold text-slate-100 flex items-center gap-1">
                        <Briefcase className="h-4 w-4 text-emerald-400" />
                        <span>{lang === 'ne' ? 'काम दिने पोर्टल' : 'Employer Portal'}</span>
                      </h1>
                      <p className="text-[10px] text-emerald-400 font-bold flex items-center gap-0.5">
                        <Check className="h-3 w-3" />
                        <span>{lang === 'ne' ? 'प्रमाणित' : 'Verified Contractor'}</span>
                      </p>
                    </div>
                    <button
                      onClick={() => {
                        setRole('worker');
                        setScreen('worker_home');
                        setWorkerTab('jobs');
                      }}
                      className="text-[10px] font-bold bg-white/10 hover:bg-white/20 text-white px-2.5 py-1.5 rounded-lg border border-white/20"
                    >
                      {lang === 'ne' ? 'कामदार मोड' : 'Worker Mode'}
                    </button>
                  </div>

                  {/* Body Content */}
                  <div className="p-4 space-y-4">
                    {/* Active postings row */}
                    <div className="space-y-2">
                      <h3 className="text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">{lang === 'ne' ? 'तपाईंका विज्ञापनहरू' : 'Your Live Postings'}</h3>
                      {jobs.filter(j => j.employerId === 'emp-verified' || j.employerId === 'emp-1').map(job => (
                        <div key={job.id} className="bg-white p-3.5 rounded-2xl border border-slate-100 shadow-sm flex justify-between items-center text-xs">
                          <div>
                            <p className="font-extrabold text-slate-900 leading-snug">{job.title}</p>
                            <p className="text-[10px] text-slate-500 font-bold mt-0.5">{job.location} • Rs. {job.wage}/day</p>
                          </div>
                          <span className="text-[10px] bg-[#E8F0FE] px-2.5 py-1 rounded-full font-black text-[#1A73E8]">
                            {applications.filter(a => a.jobId === job.id).length} applicants
                          </span>
                        </div>
                      ))}
                    </div>

                    {/* Labor directory catalog */}
                    <div className="space-y-3 pt-2">
                      <div className="flex justify-between items-center">
                        <h3 className="text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">{lang === 'ne' ? 'नजिकैका उपलब्ध कामदारहरू' : 'Browse Available Workers'}</h3>
                        <span className="text-[9px] bg-emerald-500/10 text-emerald-600 px-2 py-0.5 rounded-full font-black uppercase">Verified ID</span>
                      </div>

                      {workers.map(worker => (
                        <div key={worker.id || worker.phone} className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm space-y-3">
                          <div className="flex justify-between items-start">
                            <div>
                              <h4 className="text-xs font-black text-slate-900 leading-tight">{worker.name}</h4>
                              <p className="text-[10px] text-slate-500 font-bold flex items-center gap-1 mt-0.5">
                                <span className="bg-slate-100 px-1.5 py-0.5 rounded text-[9px] text-slate-600 font-extrabold uppercase">{worker.mainSkill}</span>
                                <span>• {worker.experience} exp</span>
                              </p>
                            </div>
                            <span className="text-xs font-black text-emerald-600 bg-emerald-50 px-2 py-1 rounded-lg">
                              Rs. {worker.expectedWage}/day
                            </span>
                          </div>

                          <p className="text-[11px] text-slate-500 italic font-medium leading-relaxed bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                            "{worker.bio || 'Available for immediate labor placement.'}"
                          </p>

                          <div className="flex items-center gap-2 pt-1">
                            <button
                              onClick={() => {
                                alert(lang === 'ne' ? 'निमन्त्रणा पठाइयो!' : 'Invitation to apply sent successfully!');
                              }}
                              className="flex-1 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-[11px] font-bold text-center transition-colors"
                            >
                              {lang === 'ne' ? 'कामको लागि बोलाउनुहोस्' : 'Invite to Job'}
                            </button>
                            <button
                              onClick={() => {
                                setCallingPhone(worker.phone);
                                setCallingName(worker.name);
                              }}
                              className="px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white text-[11px] font-bold flex items-center gap-1 shadow-sm"
                            >
                              <Phone className="h-3.5 w-3.5" />
                              <span>{lang === 'ne' ? 'कल' : 'Call'}</span>
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* === TAB: POST JOB === */}
              {employerTab === 'post' && (
                <div className="flex-1 p-4 space-y-4 animate-fadeIn">
                  <form onSubmit={handlePostJob} className="bg-white p-4.5 rounded-2xl border border-slate-100 shadow-sm space-y-4">
                    <h2 className="text-sm font-black text-slate-950 tracking-tight flex items-center gap-1">
                      <Plus className="h-4.5 w-4.5 text-[#1A73E8]" />
                      <span>{lang === 'ne' ? 'नयाँ कामको विज्ञापन थप्नुहोस्' : 'Publish New Advertisement'}</span>
                    </h2>

                    {/* Title */}
                    <div className="space-y-1">
                      <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">{lang === 'ne' ? 'कामको शीर्षक' : 'Job Title'}</label>
                      <input
                        type="text"
                        required
                        value={postTitle}
                        onChange={(e) => setPostTitle(e.target.value)}
                        placeholder="e.g. Mason for House Brick laying"
                        className="w-full bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-xl text-xs focus:outline-none focus:border-slate-950 font-semibold shadow-inner"
                      />
                    </div>

                    {/* Category Selection */}
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-1">
                        <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">{lang === 'ne' ? 'कामको विधा' : 'Category'}</label>
                        <select
                          value={postCategory}
                          onChange={(e) => setPostCategory(e.target.value)}
                          className="w-full bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-xl text-xs focus:outline-none focus:border-slate-950 font-semibold"
                        >
                          {SKILL_CATEGORIES.map(cat => (
                            <option key={cat.id} value={cat.id}>{lang === 'ne' ? cat.nameNe.split(' ')[0] : cat.nameEn.split(' ')[0]}</option>
                          ))}
                        </select>
                      </div>

                      <div className="space-y-1">
                        <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">{lang === 'ne' ? 'ज्याला (प्रतिदिन)' : 'Daily Wage'}</label>
                        <input
                          type="number"
                          required
                          value={postWage}
                          onChange={(e) => setPostWage(parseInt(e.target.value) || 1000)}
                          className="w-full bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-xl text-xs focus:outline-none focus:border-slate-950 font-semibold shadow-inner"
                        />
                      </div>
                    </div>

                    {/* Location */}
                    <div className="space-y-1">
                      <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">{lang === 'ne' ? 'ठेगाना' : 'Location'}</label>
                      <select
                        value={postLocation}
                        onChange={(e) => setPostLocation(e.target.value)}
                        className="w-full bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-xl text-xs focus:outline-none focus:border-slate-950 font-semibold"
                      >
                        {NEPAL_LOCATIONS.map(loc => (
                          <option key={loc} value={loc}>{loc}</option>
                        ))}
                      </select>
                    </div>

                    {/* Description */}
                    <div className="space-y-1">
                      <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">{lang === 'ne' ? 'विवरण' : 'Details'}</label>
                      <textarea
                        rows={2.5}
                        value={postDesc}
                        onChange={(e) => setPostDesc(e.target.value)}
                        placeholder="Describe exact requirements..."
                        className="w-full bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-xl text-xs focus:outline-none focus:border-slate-950 font-semibold shadow-inner"
                      />
                    </div>

                    <button
                      type="submit"
                      className="w-full py-3.5 mt-2 rounded-xl bg-slate-900 text-white font-bold text-xs hover:bg-slate-800 shadow transition-colors transform active:scale-95"
                    >
                      {lang === 'ne' ? 'काम प्रकाशित गर्नुहोस्' : 'Publish Live Ad'}
                    </button>
                  </form>
                </div>
              )}

              {/* === TAB: APPLICANTS === */}
              {employerTab === 'applicants' && (
                <div className="flex-1 p-4 space-y-3 animate-fadeIn">
                  <h3 className="text-sm font-black text-slate-900 uppercase tracking-tight mb-2">{lang === 'ne' ? 'प्राप्त आवेदनहरू' : 'Active Applications'}</h3>
                  {applications.length === 0 ? (
                    <div className="text-center py-10 bg-white border border-slate-100 rounded-2xl text-slate-400 text-xs">No applicants yet.</div>
                  ) : (
                    applications.map((app) => {
                      const associatedJob = jobs.find(j => j.id === app.jobId);
                      return (
                        <div key={app.id} className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex flex-col gap-3">
                          <div className="flex justify-between items-start">
                            <div>
                              <h4 className="text-xs font-black text-slate-900 leading-tight">{app.workerName}</h4>
                              <p className="text-[10px] text-slate-500 mt-0.5">Applied to: <strong className="text-slate-700">{associatedJob?.title}</strong></p>
                            </div>
                            <span className={`text-[9px] px-2 py-0.5 rounded-full font-bold border ${
                              app.status === 'accepted' 
                                ? 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20' 
                                : app.status === 'rejected' 
                                  ? 'bg-red-500/10 text-red-500 border-red-500/20' 
                                  : 'bg-slate-100 text-slate-500 border-slate-200'
                            }`}>
                              {app.status.toUpperCase()}
                            </span>
                          </div>

                          <div className="grid grid-cols-2 gap-2 text-[10px] py-1 border-t border-b border-slate-100 bg-slate-50/50 p-2 rounded-lg">
                            <div>
                              <span className="text-slate-400 block uppercase font-bold text-[8px]">Category</span>
                              <span className="font-extrabold text-slate-700">{app.workerSkill.toUpperCase()}</span>
                            </div>
                            <div>
                              <span className="text-slate-400 block uppercase font-bold text-[8px]">Expected Wage</span>
                              <span className="font-extrabold text-slate-700">Rs. 1,200/day</span>
                            </div>
                          </div>

                          {/* Actions */}
                          <div className="flex items-center gap-2">
                            {app.status === 'pending' && (
                              <>
                                <button
                                  onClick={() => handleUpdateApplicantStatus(app.id, 'rejected')}
                                  className="flex-1 py-1.5 rounded-lg bg-slate-100 text-red-500 font-bold text-[10px] hover:bg-slate-200"
                                >
                                  {lang === 'ne' ? 'अस्वीकार' : 'Reject'}
                                </button>
                                <button
                                  onClick={() => handleUpdateApplicantStatus(app.id, 'accepted')}
                                  className="flex-1 py-1.5 rounded-lg bg-emerald-500 text-white font-bold text-[10px] hover:bg-emerald-600"
                                >
                                  {lang === 'ne' ? 'स्वीकार गर्नुहोस्' : 'Accept'}
                                </button>
                              </>
                            )}

                            {/* Simulated Call / Dial */}
                            <button
                              onClick={() => {
                                setCallingPhone(app.workerPhone);
                                setCallingName(app.workerName);
                              }}
                              className="px-3 py-1.5 rounded-lg bg-slate-900 text-white font-bold text-[10px] flex items-center gap-1 hover:bg-slate-800"
                            >
                              <Phone className="h-3 w-3" />
                              <span>{lang === 'ne' ? 'फोन' : 'Call'}</span>
                            </button>
                          </div>
                        </div>
                      );
                    })
                  )}
                </div>
              )}

              {/* === TAB: CHAT === */}
              {employerTab === 'chat' && (
                <div className="flex-1 flex flex-col h-full bg-slate-50 animate-fadeIn">
                  {activeChatChannel ? (
                    /* Active Chat conversation */
                    <div className="flex-1 flex flex-col h-full bg-slate-100">
                      {/* Chat Header */}
                      <div className="bg-slate-900 text-white p-3 flex items-center justify-between sticky top-0 z-10">
                        <button onClick={() => setActiveChatChannel(null)} className="flex items-center gap-1 text-xs text-slate-300 font-bold hover:text-white">
                          <ArrowLeft className="h-4 w-4" />
                          <span>{lang === 'ne' ? 'फिर्ता' : 'Back'}</span>
                        </button>
                        <span className="font-extrabold text-xs">{activeChatChannel}</span>
                        <div className="w-5 h-5 rounded-full bg-emerald-500 flex items-center justify-center">
                          <div className="w-2.5 h-2.5 rounded-full bg-white animate-ping" />
                        </div>
                      </div>

                      {/* Messages scroll content */}
                      <div className="flex-1 overflow-y-auto p-4 space-y-3">
                        {(chatMessages[activeChatChannel] || []).map((msg, idx) => (
                          <div key={idx} className={`flex flex-col max-w-[80%] ${msg.sender === 'user' ? 'ml-auto items-end' : 'mr-auto items-start'}`}>
                            <div className={`p-3 rounded-2xl text-xs font-semibold leading-relaxed ${
                              msg.sender === 'user' ? 'bg-indigo-600 text-white rounded-br-none shadow-md shadow-indigo-600/10' : 'bg-white text-slate-800 rounded-bl-none border border-slate-200'
                            }`}>
                              {msg.text}
                            </div>
                            <span className="text-[9px] text-slate-400 mt-1 px-1 font-bold">{msg.time}</span>
                          </div>
                        ))}
                      </div>

                      {/* Presets suggestions */}
                      <div className="bg-white/80 backdrop-blur-sm p-2 border-t border-slate-200 flex gap-1.5 overflow-x-auto no-scrollbar">
                        {[
                          lang === 'ne' ? 'तपाईं कहिले आउन सक्नुहुन्छ?' : 'When can you start?',
                          lang === 'ne' ? 'काम राम्रो गर्नुपर्छ।' : 'Quality work is expected.',
                          lang === 'ne' ? 'ज्याला १२ सय दिनेछु।' : 'Wages will be Rs. 1200.'
                        ].map((preset, pIdx) => (
                          <button
                            key={pIdx}
                            onClick={() => {
                              setNewMsgText(preset);
                            }}
                            className="bg-slate-100 hover:bg-slate-200 text-slate-700 text-[10px] font-bold px-3 py-1.5 rounded-full shrink-0 border border-slate-200 transition-colors"
                          >
                            {preset}
                          </button>
                        ))}
                      </div>

                      {/* Chat Input row */}
                      <div className="bg-white p-3 border-t border-slate-200 flex items-center gap-2">
                        <input
                          type="text"
                          value={newMsgText}
                          onChange={(e) => setNewMsgText(e.target.value)}
                          onKeyDown={(e) => e.key === 'Enter' && handleSendChatMessage(activeChatChannel)}
                          placeholder={lang === 'ne' ? 'सन्देश लेख्नुहोस्...' : 'Type message...'}
                          className="flex-1 bg-slate-50 px-4 py-2.5 rounded-full border border-slate-200 text-xs focus:outline-none focus:border-indigo-500 font-semibold shadow-inner"
                        />
                        <button
                          onClick={() => handleSendChatMessage(activeChatChannel)}
                          className="bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-black px-4 py-2.5 rounded-full shadow transition-all transform active:scale-95 shrink-0"
                        >
                          {lang === 'ne' ? 'पठाउनुहोस्' : 'Send'}
                        </button>
                      </div>
                    </div>
                  ) : (
                    /* Chats directory channels */
                    <div className="flex-1 p-4 space-y-3">
                      <h2 className="text-sm font-black text-slate-900 uppercase tracking-tight">{lang === 'ne' ? 'मेरो च्याटहरू' : 'Your Chat Inbox'}</h2>
                      {['Hari Bahadur Shrestha'].map((user) => {
                        const lastMsg = chatMessages[user]?.[chatMessages[user].length - 1];
                        return (
                          <button
                            key={user}
                            onClick={() => setActiveChatChannel(user)}
                            className="w-full bg-white p-3.5 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-3.5 hover:border-slate-300 transition-all text-left"
                          >
                            <div className="w-10 h-10 rounded-full bg-indigo-500/10 text-indigo-600 flex items-center justify-center font-black text-sm border border-indigo-500/20 shrink-0">
                              {user.charAt(0)}
                            </div>
                            <div className="flex-1 min-w-0">
                              <div className="flex justify-between items-center">
                                <span className="text-xs font-extrabold text-slate-900">{user}</span>
                                <span className="text-[9px] text-slate-400 font-bold">{lastMsg?.time || 'Now'}</span>
                              </div>
                              <p className="text-[10px] text-slate-500 truncate mt-0.5">{lastMsg?.text || 'No messages yet.'}</p>
                            </div>
                          </button>
                        );
                      })}
                    </div>
                  )}
                </div>
              )}

              {/* === TAB: SYNC === */}
              {employerTab === 'sync' && (
                <div className="flex-1 p-5 space-y-4 animate-fadeIn flex flex-col justify-between">
                  <div className="space-y-4">
                    <h2 className="text-sm font-black text-slate-900 uppercase tracking-tight flex items-center gap-1.5">
                      <RefreshCw className="h-4.5 w-4.5 text-indigo-500" />
                      <span>{lang === 'ne' ? 'सिंक र अफलाइन प्रणाली' : 'Sync HUD Manager'}</span>
                    </h2>

                    {/* Network connectivity toggle simulation */}
                    <div className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
                      <div className="space-y-1">
                        <span className="text-xs font-extrabold text-slate-900">{lang === 'ne' ? 'इन्टरनेट जडान' : 'Internet Connection'}</span>
                        <p className="text-[10px] text-slate-400">{lang === 'ne' ? 'वाइफाइ वा मोबाइल डाटा' : 'Toggle WiFi/Mobile Data'}</p>
                      </div>
                      <button
                        onClick={() => setIsOnline(!isOnline)}
                        className={`px-4 py-2 rounded-xl text-xs font-extrabold border transition-all ${
                          isOnline 
                            ? 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20' 
                            : 'bg-red-500/10 text-red-500 border-red-500/20'
                        }`}
                      >
                        {isOnline ? (lang === 'ne' ? 'अनलाइन' : 'ONLINE') : (lang === 'ne' ? 'अफलाइन' : 'OFFLINE')}
                      </button>
                    </div>

                    {/* Sync actions card */}
                    <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4 text-center">
                      <div className="mx-auto w-20 h-20 rounded-full bg-indigo-50 flex items-center justify-center relative">
                        {isSyncing ? (
                          <Loader2 className="h-10 w-10 text-indigo-600 animate-spin" />
                        ) : (
                          <RefreshCw className="h-8 w-8 text-indigo-600" />
                        )}
                        {isSyncing && (
                          <span className="absolute inset-0 rounded-full border-4 border-indigo-600 border-t-transparent animate-spin" />
                        )}
                      </div>

                      <div className="space-y-1">
                        <span className="text-xs font-extrabold text-slate-900">{lang === 'ne' ? 'डाटाबेस सिंक्रोनाइजेसन' : 'Offline Database Sync'}</span>
                        <p className="text-[10px] text-slate-400 leading-relaxed max-w-xs mx-auto">
                          {lang === 'ne' 
                            ? 'मोबाइल डाटा महँगो हुन्छ। नेपालको जुनसुकै स्थानमा काम खोज्न पहिले नै सबै विज्ञापनहरू फोनमा सिंक गर्नुहोस्।' 
                            : 'Wages and listings are downloaded locally. Find labor opportunities without burning mobile data balances at site.'}
                        </p>
                      </div>

                      {isSyncing ? (
                        <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                          <div className="bg-indigo-600 h-full transition-all duration-150" style={{ width: `${syncProgress}%` }} />
                        </div>
                      ) : (
                        <button
                          onClick={handleSyncDatabase}
                          className="w-full py-3.5 rounded-xl bg-slate-900 text-white text-xs font-black hover:bg-slate-800 transition-colors active:scale-95"
                        >
                          {lang === 'ne' ? 'अहिले नै सिंक गर्नुहोस्' : 'SYNCHRONIZE OFFLINE DATABASE'}
                        </button>
                      )}

                      <div className="text-[10px] text-slate-400 font-bold flex justify-between px-1">
                        <span>Last sync: {lastSyncTime}</span>
                        <span>Cache: {jobs.length} jobs stored</span>
                      </div>
                    </div>
                  </div>

                  <p className="text-[9px] text-center text-slate-400 font-bold">
                    ROJGAR Nepalese Labor Platform • Version 1.0.2 Offline HUD
                  </p>
                </div>
              )}

              {/* === TAB: PROFILE === */}
              {employerTab === 'profile' && (
                <div className="flex-1 p-4 space-y-4 animate-fadeIn">
                  {/* Top brand header from reference image */}
                  <div className="flex items-center justify-between py-1 bg-transparent">
                    <div className="flex items-center gap-3">
                      {/* Circle blue logo with diamond design */}
                      <div className="w-11 h-11 rounded-full bg-[#005bb5] flex items-center justify-center shadow shadow-blue-800/20 shrink-0">
                        <div className="w-5 h-5 border-2 border-white rotate-45 flex items-center justify-center">
                          <div className="w-2 h-2 bg-white rounded-full" />
                        </div>
                      </div>
                      <div className="space-y-0.5">
                        <h2 className="text-base font-black text-slate-900 tracking-tight leading-none">ROJGAR FINDER</h2>
                        <p className="text-[10px] font-bold text-slate-500">रोजगार खोजकर्ता • Nepal</p>
                      </div>
                    </div>

                    {/* Online indicator badge */}
                    <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-blue-50/80 border border-blue-100 text-blue-600 font-extrabold text-[11px] tracking-tight">
                      <span className="h-2 w-2 rounded-full bg-emerald-500 inline-block animate-pulse" />
                      <span>ONLINE</span>
                    </span>
                  </div>

                  {/* Dynamic Active Profile Card */}
                  {(() => {
                    const activeEmp = employers.find(e => e.phone === phone) || {
                      name: 'Ajay Gupta',
                      role: 'Contractor',
                      companyName: 'Gupta Construction & Co.',
                      phone: phone || '9851044321',
                      location: 'Balkumari, Lalitpur',
                      govId: 'CIT-98510-NP',
                      profilePhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80',
                      isVerified: true
                    };

                    if (isEditingProfile) {
                      return (
                        <div className="space-y-4 animate-fadeIn bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
                          <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
                            <button
                              type="button"
                              onClick={() => setIsEditingProfile(false)}
                              className="p-1 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-full transition-colors"
                            >
                              <ArrowLeft className="h-4.5 w-4.5" />
                            </button>
                            <div>
                              <h3 className="text-xs font-black text-slate-900 tracking-tight uppercase">
                                {lang === 'ne' ? 'प्रोफाइल सम्पादन' : 'Edit Profile Info'}
                              </h3>
                              <p className="text-[9px] text-slate-400 font-bold uppercase">
                                {lang === 'ne' ? 'विवरण परिमार्जन गर्नुहोस्' : 'Update your identity details'}
                              </p>
                            </div>
                          </div>

                          {/* Profile Photo selector */}
                          <div className="space-y-2 flex flex-col items-center">
                            <label className="text-[9px] font-extrabold text-slate-400 uppercase tracking-wider block">
                              {lang === 'ne' ? 'प्रोफाइल फोटो' : 'Profile Photo'}
                            </label>
                            <img
                              src={editEmpPhoto || activeEmp.profilePhoto}
                              alt="Profile Preview"
                              referrerPolicy="no-referrer"
                              className="w-14 h-14 rounded-full border-2 border-[#1A73E8] object-cover bg-slate-50 shadow-sm"
                            />
                            <label className="px-2 py-1 bg-slate-50 border border-slate-200 text-[9px] text-slate-600 font-bold rounded-lg cursor-pointer hover:bg-slate-100">
                              <span>{lang === 'ne' ? 'फोटो परिवर्तन गर्नुहोस्' : 'Upload photo'}</span>
                              <input
                                type="file"
                                accept="image/*"
                                className="hidden"
                                onChange={(e) => {
                                  const file = e.target.files?.[0];
                                  if (file) {
                                    setEditEmpPhoto(URL.createObjectURL(file));
                                  }
                                }}
                              />
                            </label>
                          </div>

                          <div className="space-y-3 pt-1">
                            {/* Name */}
                            <div className="space-y-1">
                              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                {lang === 'ne' ? 'रोजगारदाताको नाम' : 'Full Name'}
                              </label>
                              <input
                                type="text"
                                value={editEmpName}
                                onChange={(e) => setEditEmpName(e.target.value)}
                                className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-[#1A73E8]"
                              />
                            </div>

                            {/* Phone */}
                            <div className="space-y-1">
                              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                {lang === 'ne' ? 'सम्पर्क नम्बर' : 'Phone Number'}
                              </label>
                              <input
                                type="text"
                                value={editEmpPhone}
                                onChange={(e) => setEditEmpPhone(e.target.value)}
                                className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-[#1A73E8]"
                              />
                            </div>

                            {/* Role and Location */}
                            <div className="grid grid-cols-2 gap-2.5">
                              <div className="space-y-1">
                                <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                  {lang === 'ne' ? 'भूमिका' : 'Role'}
                                </label>
                                <select
                                  value={editEmpRole}
                                  onChange={(e) => setEditEmpRole(e.target.value)}
                                  className="w-full bg-white px-2 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-[#1A73E8]"
                                >
                                  <option value="Contractor">Contractor</option>
                                  <option value="Sub-contractor">Sub-contractor</option>
                                  <option value="Home Owner">Home Owner</option>
                                  <option value="Business Owner">Business Owner</option>
                                </select>
                              </div>

                              <div className="space-y-1">
                                <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                  {lang === 'ne' ? 'स्थान' : 'Location'}
                                </label>
                                <select
                                  value={editEmpLocation}
                                  onChange={(e) => setEditEmpLocation(e.target.value)}
                                  className="w-full bg-white px-2 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-[#1A73E8]"
                                >
                                  {NEPAL_LOCATIONS.map(loc => (
                                    <option key={loc} value={loc}>{loc}</option>
                                  ))}
                                </select>
                              </div>
                            </div>

                            {/* Company Name */}
                            <div className="space-y-1">
                              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                {lang === 'ne' ? 'कम्पनी / फर्म' : 'Company Name'}
                              </label>
                              <input
                                type="text"
                                value={editEmpCompany}
                                onChange={(e) => setEditEmpCompany(e.target.value)}
                                className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-[#1A73E8]"
                              />
                            </div>

                            {/* Gov ID */}
                            <div className="space-y-1">
                              <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">
                                {lang === 'ne' ? 'सरकारी परिचय-पत्र नम्बर' : 'Government Verification ID'}
                              </label>
                              <input
                                type="text"
                                value={editEmpGovId}
                                onChange={(e) => setEditEmpGovId(e.target.value)}
                                className="w-full bg-white px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-[#1A73E8]"
                              />
                            </div>

                            {/* Actions */}
                            <div className="flex gap-2 pt-2 border-t border-slate-100">
                              <button
                                type="button"
                                onClick={() => setIsEditingProfile(false)}
                                className="flex-1 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs"
                              >
                                {lang === 'ne' ? 'रद्द' : 'Cancel'}
                              </button>
                              <button
                                type="button"
                                onClick={() => {
                                  if (!editEmpName.trim()) {
                                    alert('Name is required');
                                    return;
                                  }
                                  handleUpdateEmployerProfile({
                                    name: editEmpName,
                                    phone: editEmpPhone,
                                    role: editEmpRole,
                                    location: editEmpLocation,
                                    companyName: editEmpCompany || 'Individual',
                                    govId: editEmpGovId,
                                    profilePhoto: editEmpPhoto || activeEmp.profilePhoto
                                  });
                                }}
                                className="flex-1 py-2.5 rounded-xl bg-[#005bb5] hover:bg-[#004b95] text-white font-extrabold text-xs"
                              >
                                {lang === 'ne' ? 'सुरक्षित गर्नुहोस्' : 'Save'}
                              </button>
                            </div>
                          </div>
                        </div>
                      );
                    }

                    return (
                      <div className="space-y-4">
                        {/* Profile Info Summary Card */}
                        <div className="bg-white border border-slate-200/60 rounded-2xl p-4 shadow-sm space-y-4">
                          <div className="flex items-center gap-3">
                            <img
                              src={activeEmp.profilePhoto}
                              alt={activeEmp.name}
                              referrerPolicy="no-referrer"
                              className="w-12 h-12 rounded-full border border-slate-200 object-cover shadow-sm shrink-0"
                            />
                            <div className="space-y-0.5 min-w-0 flex-1">
                              <div className="flex items-center gap-1 flex-wrap">
                                <h4 className="text-sm font-black text-slate-950 truncate">{activeEmp.name}</h4>
                                {activeEmp.isVerified && (
                                  <span className="text-[9px] bg-emerald-500/15 text-emerald-700 font-extrabold px-1.5 py-0.5 rounded flex items-center gap-0.5 shrink-0">
                                    <Check className="h-2.5 w-2.5 text-emerald-600 stroke-[3]" />
                                    <span>VERIFIED</span>
                                  </span>
                                )}
                              </div>
                              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                                {activeEmp.role} • {activeEmp.companyName}
                              </p>
                            </div>
                          </div>

                          <div className="border-t border-slate-100 pt-3.5 space-y-2">
                            <div className="flex justify-between items-center text-xs">
                              <span className="font-bold text-slate-400">{lang === 'ne' ? 'मोबाइल नम्बर' : 'Phone Number'}</span>
                              <span className="font-extrabold text-slate-800">+977 {activeEmp.phone}</span>
                            </div>
                            <div className="flex justify-between items-center text-xs">
                              <span className="font-bold text-slate-400">{lang === 'ne' ? 'मुख्य स्थान' : 'Main Location'}</span>
                              <span className="font-extrabold text-slate-800">{activeEmp.location}</span>
                            </div>
                            <div className="flex justify-between items-center text-xs">
                              <span className="font-bold text-slate-400">{lang === 'ne' ? 'सरकारी परिचय-पत्र' : 'Government Verification ID'}</span>
                              <span className="font-extrabold text-[#1A73E8] bg-[#1A73E8]/5 px-2 py-0.5 rounded border border-[#1A73E8]/10 text-[10px]">
                                {activeEmp.govId || 'N/A'}
                              </span>
                            </div>
                          </div>

                          <button
                            onClick={() => {
                              setEditEmpName(activeEmp.name);
                              setEditEmpPhone(activeEmp.phone);
                              setEditEmpRole(activeEmp.role || 'Contractor');
                              setEditEmpLocation(activeEmp.location);
                              setEditEmpCompany(activeEmp.companyName);
                              setEditEmpGovId(activeEmp.govId || '');
                              setEditEmpPhoto(activeEmp.profilePhoto || '');
                              setIsEditingProfile(true);
                            }}
                            className="w-full py-2.5 bg-slate-50 hover:bg-slate-100 text-[#005bb5] font-extrabold text-xs rounded-xl border border-slate-200 transition-colors flex items-center justify-center gap-1.5 active:scale-[0.98]"
                          >
                            <span>✏️</span>
                            <span>{lang === 'ne' ? 'प्रोफाइल विवरण परिमार्जन गर्नुहोस्' : 'Edit Profile Information'}</span>
                          </button>
                        </div>

                        {/* Profile section header */}
                        <h3 className="text-sm font-black text-slate-900 tracking-tight flex items-center gap-2 mt-2">
                          <span className="text-slate-500">⚙️</span>
                          <span>{lang === 'ne' ? 'प्रणाली सेटिंग्स र प्राथमिकताहरू' : 'Profile & System Settings'}</span>
                        </h3>

                        {/* System Settings & Customization Card */}
                        <div className="bg-white border border-slate-200/60 rounded-2xl p-4 shadow-sm space-y-4">
                          {/* Language Preference selection */}
                          <div className="flex items-center justify-between border-b border-slate-50 pb-3">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'एपको भाषा' : 'Application Language'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'एपको लागि भाषा चयन' : 'Change app interface language'}
                              </span>
                            </div>
                            <div className="flex gap-1.5 bg-slate-50 p-1 rounded-xl border border-slate-200/60">
                              <button
                                onClick={() => setLang('en')}
                                className={`px-2.5 py-1 rounded-lg text-[10px] font-black transition-all ${
                                  lang === 'en' ? 'bg-[#005bb5] text-white shadow-sm' : 'text-slate-500 hover:text-slate-800'
                                }`}
                              >
                                English
                              </button>
                              <button
                                onClick={() => setLang('ne')}
                                className={`px-2.5 py-1 rounded-lg text-[10px] font-black transition-all ${
                                  lang === 'ne' ? 'bg-[#005bb5] text-white shadow-sm' : 'text-slate-500 hover:text-slate-800'
                                }`}
                              >
                                नेपाली
                              </button>
                            </div>
                          </div>

                          {/* Theme Preference selection */}
                          <div className="flex items-center justify-between border-b border-slate-50 pb-3">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'एपको थिम' : 'Application Theme'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'लाइट, डार्क वा सिस्टम थिम' : 'Light, Dark, or System theme'}
                              </span>
                            </div>
                            <div className="flex gap-1 bg-slate-50 p-1 rounded-xl border border-slate-200/60">
                              {[
                                { id: 'light', labelEn: 'Light', labelNe: 'लाइट' },
                                { id: 'dark', labelEn: 'Dark', labelNe: 'डार्क' },
                                { id: 'system', labelEn: 'System', labelNe: 'सिस्टम' }
                              ].map(t => (
                                <button
                                  key={t.id}
                                  onClick={() => setThemePref(t.id as any)}
                                  className={`px-2 py-1 rounded-lg text-[10px] font-black transition-all ${
                                    themePref === t.id ? 'bg-[#005bb5] text-white shadow-sm' : 'text-slate-500 hover:text-slate-800'
                                  }`}
                                >
                                  {lang === 'ne' ? t.labelNe : t.labelEn}
                                </button>
                              ))}
                            </div>
                          </div>

                          {/* Voice Assistant Toggle */}
                          <div className="flex items-center justify-between border-b border-slate-50 pb-3">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'ध्वनि/आवाज सहायता' : 'Voice Assistance Synthesizer'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'बोलेर कामदार खोज्ने सहायता' : 'Speak-aloud voice prompts'}
                              </span>
                            </div>
                            <button
                              onClick={() => setVoiceFeedbackEnabled(!voiceFeedbackEnabled)}
                              className={`w-11 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${
                                voiceFeedbackEnabled ? 'bg-emerald-500' : 'bg-slate-200'
                              }`}
                            >
                              <div
                                className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${
                                  voiceFeedbackEnabled ? 'translate-x-5' : 'translate-x-0'
                                }`}
                              />
                            </button>
                          </div>

                          {/* Sound alerts on match log Toggle */}
                          <div className="flex items-center justify-between">
                            <div>
                              <span className="text-xs font-black text-slate-800 block">
                                {lang === 'ne' ? 'नयाँ कामदार मिलान सङ्केत' : 'Worker Match Audio Alerts'}
                              </span>
                              <span className="text-[9px] font-bold text-slate-400 uppercase">
                                {lang === 'ne' ? 'सङ्केत ध्वनीहरू प्ले गर्ने' : 'Sound alert on match discovery'}
                              </span>
                            </div>
                            <button
                              onClick={() => setSoundAlertsEnabled(!soundAlertsEnabled)}
                              className={`w-11 h-6 rounded-full p-1 transition-colors duration-200 focus:outline-none ${
                                soundAlertsEnabled ? 'bg-emerald-500' : 'bg-slate-200'
                              }`}
                            >
                              <div
                                className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${
                                  soundAlertsEnabled ? 'translate-x-5' : 'translate-x-0'
                                }`}
                              />
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })()}

                  {/* Match Logs header and Clear Logs row */}
                  <div className="flex justify-between items-center mt-2 px-1">
                    <span className="text-xs font-black text-slate-800 flex items-center gap-1.5">
                      <span>🔔</span>
                      <span>In-App Match Logs ({matchLogs.length})</span>
                    </span>
                    <button 
                      onClick={() => setMatchLogs([])}
                      className="text-xs font-bold text-red-500 hover:underline"
                    >
                      Clear Logs
                    </button>
                  </div>

                  {/* Match logs display card */}
                  <div className="bg-white border border-slate-200/60 rounded-2xl p-5 shadow-sm">
                    {matchLogs.length === 0 ? (
                      <p className="text-xs font-semibold text-slate-400 text-center leading-relaxed">
                        No match alert logs. Complete offline synchronizations to download matches!
                      </p>
                    ) : (
                      <div className="space-y-2 max-h-36 overflow-y-auto">
                        {matchLogs.map((log, lIdx) => (
                          <div key={lIdx} className="text-[10px] font-bold text-slate-600 p-2 bg-slate-50 rounded-lg border border-slate-100 flex items-center gap-1.5">
                            <span className="h-1.5 w-1.5 rounded-full bg-blue-500 shrink-0" />
                            <span>{log}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Logout Button */}
                  <button
                    onClick={() => {
                      setScreen('language_selection');
                      setPhone('');
                      setOtpSent(false);
                      setOtpCode('');
                      setRole(null);
                      setWorkerTab('jobs');
                      setEmployerTab('jobs');
                    }}
                    className="w-full py-3.5 bg-red-50 text-red-600 border border-red-200 hover:bg-red-100 font-black rounded-2xl text-[11px] tracking-wider transition-colors active:scale-[0.98] uppercase text-center flex items-center justify-center gap-1.5 mt-2"
                  >
                    <span>LOGOUT ACCOUNT (बाहिर निस्कनुहोस्)</span>
                  </button>
                </div>
              )}

            </div>

            {/* Employer Tab Navigation Bar */}
            <div className="h-16 bg-white border-t border-slate-100 flex items-center justify-around px-1 z-30 select-none shrink-0 shadow-lg shadow-slate-900/10">
              {[
                { id: 'jobs', label: lang === 'ne' ? 'कामहरू' : 'Jobs', icon: Briefcase },
                { id: 'post', label: lang === 'ne' ? 'थप्नुहोस्' : 'Post Job', icon: Plus },
                { id: 'applicants', label: lang === 'ne' ? 'आवेदक' : 'Applicants', icon: ClipboardList },
                { id: 'chat', label: lang === 'ne' ? 'च्याट' : 'Chat', icon: MessageSquare },
                { id: 'sync', label: lang === 'ne' ? 'सिंक HUD' : 'Sync HUD', icon: RefreshCw },
                { id: 'profile', label: lang === 'ne' ? 'प्रोफाइल' : 'Profile', icon: Settings }
              ].map((tab) => {
                const Icon = tab.icon;
                const isActive = employerTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    onClick={() => {
                      setEmployerTab(tab.id as any);
                      setActiveChatChannel(null);
                    }}
                    className="flex flex-col items-center justify-center flex-1 py-1"
                  >
                    <div className={`p-1 px-3 rounded-full transition-all ${
                      isActive ? 'bg-[#E8F0FE] text-[#1A73E8]' : 'text-slate-400 hover:text-slate-600'
                    }`}>
                      <Icon className="h-5 w-5" />
                    </div>
                    <span className={`text-[9px] mt-1 font-bold ${
                      isActive ? 'text-slate-900 font-extrabold' : 'text-slate-500 font-semibold'
                    }`}>
                      {tab.label}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        )}

      </div>

      {/* Navigation Bar at Bottom (Simulated OS buttons) */}
      <div className="h-12 bg-[#0F0F12] border-t border-white/5 flex items-center justify-around px-10 text-slate-400 z-50">
        <button 
          onClick={() => {
            if (screen === 'worker_home' || screen === 'employer_home') {
              setScreen('role_selection');
            } else if (screen === 'role_selection') {
              setScreen('login');
            } else if (screen === 'login') {
              setScreen('language_selection');
            }
          }}
          className="hover:text-white transition-colors"
          title="Back"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <button 
          onClick={() => {
            setScreen('language_selection');
            setPhone('');
            setOtpSent(false);
            setOtpCode('');
            setRole(null);
          }}
          className="hover:text-white transition-colors"
          title="Home"
        >
          <div className="w-4 h-4 rounded-full border-2 border-slate-400" />
        </button>
        <button 
          onClick={() => {
            // Simulator info reset or reset states
            if(confirm("Reset simulator database to defaults?")) {
              localStorage.clear();
              window.location.reload();
            }
          }}
          className="hover:text-white transition-colors text-[10px] font-bold"
          title="Reset Database"
        >
          RESET
        </button>
      </div>

      {/* ==================== DIALOG/MODAL: ACTIVE JOB DETAILS ==================== */}
      {activeJobDetails && (
        <div className="absolute inset-x-0 bottom-12 top-10 bg-black/50 z-50 animate-fadeIn" onClick={() => setActiveJobDetails(null)}>
          <div 
            className="absolute bottom-0 inset-x-0 bg-white rounded-t-3xl max-h-[85%] overflow-y-auto p-5 space-y-4"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="w-12 h-1.5 bg-slate-200 rounded-full mx-auto" />
            
            {/* Title & Audio Play Row */}
            <div className="flex justify-between items-start gap-4">
              <h2 className="text-sm font-black text-slate-950 leading-snug">{activeJobDetails.title}</h2>
              <button
                onClick={() => handlePlayJobAudio(activeJobDetails)}
                className="p-2 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-800 transition-colors shrink-0"
                title="Read details audibly (TTS)"
              >
                <Volume2 className="h-4.5 w-4.5" />
              </button>
            </div>

            {/* Wage detail */}
            <div className="p-3 bg-emerald-500/10 rounded-xl border border-emerald-500/20 flex items-center justify-between text-xs text-emerald-600 font-bold">
              <span>{lang === 'ne' ? 'प्रस्तावित ज्याला:' : 'Expected Wage:'}</span>
              <span className="text-sm font-black">Rs. {activeJobDetails.wage} / Day</span>
            </div>

            {/* Description */}
            <div className="space-y-1">
              <span className="text-[9px] uppercase font-bold text-slate-400">{lang === 'ne' ? 'विवरण' : 'Job Details'}</span>
              <p className="text-xs text-slate-600 leading-relaxed">{activeJobDetails.description}</p>
            </div>

            {/* Technical meta data row */}
            <div className="grid grid-cols-2 gap-3 text-[10px] border-t border-slate-100 pt-3">
              <div>
                <span className="text-slate-400 block font-bold uppercase text-[8px]">{lang === 'ne' ? 'ठेगाना' : 'Location'}</span>
                <span className="font-extrabold text-slate-700">{activeJobDetails.location}</span>
              </div>
              <div>
                <span className="text-slate-400 block font-bold uppercase text-[8px]">{lang === 'ne' ? 'रोजगारदाता' : 'Employer'}</span>
                <span className="font-extrabold text-slate-700">{activeJobDetails.employerName}</span>
              </div>
            </div>

            {/* Direct Connect Options */}
            <div className="space-y-2 pt-2">
              <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">
                {lang === 'ne' ? 'सिधा रोजगारदाता सम्पर्क' : 'Direct Employer Connection'}
              </p>
              <div className="flex gap-2">
                <button
                  onClick={() => {
                    setCallingPhone(activeJobDetails.employerPhone);
                    setCallingName(activeJobDetails.employerName);
                  }}
                  className="flex-1 py-3 bg-slate-900 hover:bg-slate-800 text-white rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 shadow"
                >
                  <Phone className="h-4 w-4" />
                  <span>{lang === 'ne' ? 'सिधा फोन' : 'Direct Call'}</span>
                </button>
                <a
                  href={`https://wa.me/977${activeJobDetails.employerPhone}`}
                  target="_blank"
                  rel="noreferrer"
                  className="flex-1 py-3 bg-emerald-500 hover:bg-emerald-600 text-white rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 shadow"
                >
                  <MessageSquare className="h-4 w-4" />
                  <span>WhatsApp</span>
                </a>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ==================== DIALOG/MODAL: SMART VOICE PARSING WIZARD ==================== */}
      {voiceInputOpen && (
        <div className="absolute inset-0 bg-slate-950/90 z-50 p-5 flex flex-col justify-between animate-fadeIn">
          <div className="space-y-4">
            <div className="flex justify-between items-center text-white">
              <span className="text-xs font-black text-emerald-400 flex items-center gap-1">
                <Sparkles className="h-4 w-4 fill-emerald-400" />
                <span>Gemini Voice Onboarding</span>
              </span>
              <button 
                onClick={() => setVoiceInputOpen(false)}
                className="text-slate-400 hover:text-white text-xs font-bold"
              >
                Close
              </button>
            </div>

            <p className="text-xs text-slate-300 leading-relaxed">
              {lang === 'ne' 
                ? 'सिमुलेटरमा आवाज रेकर्ड गर्न तलका कुनै पनि उदाहरण थिच्नुहोस् वा आफ्नै वाक्य टाइप गर्नुहोस्। एआईले तपाइको विवरण पत्ता लगाउनेछ!' 
                : 'Tap any preset speech dictation below to simulate speaking, or type your own description. Gemini will extract name, skill, location, and daily wages!'}
            </p>

            {/* Presets Grid */}
            <div className="space-y-2 pt-2">
              <span className="text-[9px] font-bold text-slate-500 uppercase tracking-wider">Preset Speaking Examples / उदाहरणहरू</span>
              {PRESET_DICTATIONS.map((p, idx) => (
                <button
                  key={idx}
                  onClick={() => {
                    const text = lang === 'ne' ? p.textNe : p.textEn;
                    setSpeechText(text);
                    handleVoiceParse(text);
                  }}
                  className="w-full p-2.5 rounded-xl bg-slate-900 border border-slate-800 text-left text-[11px] hover:border-emerald-500 transition-colors"
                >
                  <p className="font-bold text-emerald-400 mb-1">{lang === 'ne' ? p.labelNe : p.labelEn}</p>
                  <p className="text-slate-400 line-clamp-2 italic">"{lang === 'ne' ? p.textNe : p.textEn}"</p>
                </button>
              ))}
            </div>

            {/* Typing box */}
            <div className="space-y-1 pt-2">
              <span className="text-[9px] font-bold text-slate-500 uppercase tracking-wider">{lang === 'ne' ? 'आफ्नो वाक्य यहाँ लेख्नुहोस् (वाइल्डकार्ड)' : 'Or write your own dictation details'}</span>
              <textarea
                value={speechText}
                onChange={(e) => setSpeechText(e.target.value)}
                placeholder={lang === 'ne' ? "मेरो नाम श्याम हो। म सिकर्मी हुँ..." : "Speak/type your work interest..."}
                className="w-full bg-slate-900 border border-slate-800 rounded-xl p-3 text-xs text-white focus:outline-none focus:border-emerald-500"
                rows={3}
              />
              {speechText.trim() !== '' && (
                <button
                  onClick={() => handleVoiceParse(speechText)}
                  className="py-2.5 px-4 bg-emerald-500 hover:bg-emerald-600 text-white rounded-lg text-xs font-bold"
                >
                  Parse with Gemini AI
                </button>
              )}
            </div>
          </div>

          {/* Parsing Results Overlay */}
          <div className="pb-4 space-y-4">
            {parsingVoice && (
              <div className="flex flex-col items-center justify-center py-6 gap-2 bg-slate-900 rounded-2xl border border-slate-800">
                <Loader2 className="h-6 w-6 text-emerald-400 animate-spin" />
                <p className="text-[11px] text-slate-300 font-bold">Gemini AI is parsing speech...</p>
              </div>
            )}

            {voiceParsedProfile && !parsingVoice && (
              <div className="p-4 bg-slate-900 rounded-2xl border border-emerald-500/30 space-y-3">
                <h3 className="text-xs font-bold text-emerald-400 flex items-center gap-1">
                  <CheckCircle className="h-4 w-4" />
                  <span>Gemini Extracted Details</span>
                </h3>
                
                <div className="space-y-2 text-xs text-slate-300 font-medium">
                  <p>👤 <strong>Name:</strong> {voiceParsedProfile.name}</p>
                  <p>🛠️ <strong>Skill:</strong> {voiceParsedProfile.mainSkill?.toUpperCase()}</p>
                  <p>💰 <strong>Wage:</strong> Rs. {voiceParsedProfile.expectedWage} / day</p>
                  <p>📍 <strong>Location:</strong> {voiceParsedProfile.location}</p>
                  {voiceParsedProfile.bio && (
                    <p className="text-[11px] text-slate-400 italic">"{voiceParsedProfile.bio}"</p>
                  )}
                </div>

                <div className="flex gap-2 pt-1">
                  <button
                    onClick={() => setVoiceParsedProfile(null)}
                    className="flex-1 py-2 rounded-lg bg-slate-800 text-slate-400 text-[10px] font-bold"
                  >
                    Discard
                  </button>
                  <button
                    onClick={() => handleCreateWorkerProfile(voiceParsedProfile)}
                    className="flex-1 py-2 rounded-lg bg-emerald-500 text-white text-[10px] font-bold"
                  >
                    Confirm & Save Profile
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* ==================== DIALOG/MODAL: SIMULATED PHONE DIALER ==================== */}
      {callingPhone && (
        <div className="absolute inset-0 bg-slate-950/95 z-50 flex flex-col justify-between items-center p-8 text-white animate-fadeIn" id="phone_dialer">
          <div className="flex flex-col items-center space-y-4 mt-16">
            <div className="w-24 h-24 rounded-full bg-slate-800 flex items-center justify-center border-4 border-slate-700 animate-pulse">
              <Phone className="h-10 w-10 text-emerald-400 fill-emerald-400" />
            </div>
            <div className="text-center space-y-1">
              <h2 className="text-xl font-black">{callingName || 'Unknown Employer'}</h2>
              <p className="text-xs text-emerald-400 font-bold tracking-widest uppercase">Calling...</p>
              <p className="text-sm text-slate-400 font-mono">+977 {callingPhone}</p>
            </div>
          </div>

          <div className="text-center space-y-4 pb-12 w-full">
            <p className="text-[11px] text-slate-500 italic max-w-xs mx-auto">
              This triggers a native telephone call widget <code>tel:+977{callingPhone}</code> on physical iOS and Android smartphones.
            </p>
            <button
              onClick={() => {
                setCallingPhone(null);
                setCallingName(null);
              }}
              className="w-16 h-16 rounded-full bg-red-600 flex items-center justify-center shadow-lg hover:bg-red-700 transition-colors transform active:scale-95 mx-auto"
            >
              <Phone className="h-6 w-6 rotate-[135deg]" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
