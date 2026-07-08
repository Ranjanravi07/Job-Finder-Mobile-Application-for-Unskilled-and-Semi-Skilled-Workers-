/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React from 'react';
import MobileSimulator from './components/MobileSimulator';

export default function App() {
  return (
    <div className="min-h-screen w-screen bg-[#0A0A0C] text-slate-300 font-sans flex items-center justify-center p-4 md:p-8 selection:bg-indigo-500 selection:text-white relative overflow-hidden" id="app_root">
      {/* Ambient background glow to match the Sophisticated Dark aesthetic */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(99,102,241,0.06)_0,transparent_75%)] pointer-events-none" />

      {/* Centered Smartphone Simulator */}
      <div className="relative z-10 w-full flex items-center justify-center" id="simulator_container">
        <MobileSimulator />
      </div>
    </div>
  );
}
