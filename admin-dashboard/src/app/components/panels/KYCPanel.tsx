import { useState, useEffect } from "react";
import { db } from "../../../firebase";
import { collection, query, where, onSnapshot, doc, updateDoc, getDoc } from "firebase/firestore";
import { 
  ShieldCheck, UserCheck, AlertCircle, RefreshCw, MapPin, Phone, 
  Clock, FileText, User, Building2, CheckCircle, XCircle, Ban, MessageSquare,
  ChevronLeft, ChevronRight, Search, Filter
} from "lucide-react";
import { Button } from "../ui/button";
import { Badge } from "../ui/badge";
import { Card } from "../ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "../ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../ui/tabs";
import { Textarea } from "../ui/textarea";
import { toast } from "sonner";
import type { ActiveFilters } from "../App";

export interface KYCRequest {
  id: string;
  userId: string;
  userName: string;
  userRole: "worker" | "employer";
  phone: string;
  location: string;
  govIdType: string;
  govIdNumber: string;
  govIdFiles: string[];
  verificationStatus: "pending" | "verified" | "rejected" | "blocked";
  submissionDate: string;
  previousKYC?: {
    govIdType: string;
    govIdNumber: string;
    govIdFiles: string[];
  };
  rejectionReason?: string;
  requestedUpdate?: boolean;
  governmentIds?: Record<string, { idNumber?: string; documentFiles?: string[]; submittedAt?: string }>;
}

const statusStyle: Record<string, string> = {
  pending: "bg-amber-500/10 text-amber-400 border border-amber-500/20",
  verified: "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  rejected: "bg-rose-500/10 text-rose-400 border border-rose-500/20",
  blocked: "bg-slate-500/10 text-slate-400 border border-slate-500/20",
};

const statusIcon: Record<string, any> = {
  pending: Clock,
  verified: CheckCircle,
  rejected: XCircle,
  blocked: Ban,
};

export default function KYCPanel({ search, filters }: {
  search: string;
  filters?: ActiveFilters;
}) {
  const [kycRequests, setKYCRequests] = useState<KYCRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedKYC, setSelectedKYC] = useState<KYCRequest | null>(null);
  const [activeTab, setActiveTab] = useState<"pending" | "verified" | "rejected" | "updates">("pending");
  const [rejectionReason, setRejectionReason] = useState("");
  const [updateRequestReason, setUpdateRequestReason] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // Fetch KYC requests from Firebase
  useEffect(() => {
    setLoading(true);
    
    // Try to fetch from Firestore if available, otherwise use dummy data for demo
    if (db) {
      // Subscribe to workers collection
      const workersQuery = query(collection(db, "workers"));
      const employersQuery = query(collection(db, "employers"));
      
      const unsubscribeWorkers = onSnapshot(workersQuery, (snapshot) => {
        const workersData = snapshot.docs.map(doc => {
          const data = doc.data();
          return {
            id: doc.id,
            userId: doc.id,
            userName: data.name || "Unknown",
            userRole: "worker" as const,
            phone: data.phone || "",
            location: data.location || "",
            govIdType: data.govIdType || "citizenship",
            govIdNumber: data.govIdNum || "",
            govIdFiles: data.govIdFiles || [],
            verificationStatus: data.verificationStatus || "pending",
            submissionDate: data.createdAt || new Date().toISOString(),
            requestedUpdate: data.requestedUpdate || false,
            rejectionReason: data.rejectionReason,
            governmentIds: data.governmentIds || undefined,
          };
        });
        
        // Subscribe to employers collection
        const unsubscribeEmployers = onSnapshot(employersQuery, (snapshot) => {
          const employersData = snapshot.docs.map(doc => {
            const data = doc.data();
            return {
              id: doc.id,
              userId: doc.id,
              userName: data.name || "Unknown",
              userRole: "employer" as const,
              phone: data.phone || "",
              location: data.location || "",
              govIdType: data.govIdType || "citizenship",
              govIdNumber: data.govIdNum || "",
              govIdFiles: data.govIdFiles || [],
              verificationStatus: data.verificationStatus || "pending",
              submissionDate: data.createdAt || new Date().toISOString(),
              requestedUpdate: data.requestedUpdate || false,
              rejectionReason: data.rejectionReason,
              governmentIds: data.governmentIds || undefined,
            };
          });
          
          const allRequests = [...workersData, ...employersData];
          setKYCRequests(allRequests);
          setLoading(false);
        });
        
        return () => unsubscribeEmployers();
      });
      
      return () => unsubscribeWorkers();
    } else {
      // Use dummy data for demo if Firebase is not available
      const dummyData: KYCRequest[] = [
        {
          id: "W-1042",
          userId: "W-1042",
          userName: "Ramon dela Cruz",
          userRole: "worker",
          phone: "+63 912 345 6789",
          location: "Manila",
          govIdType: "citizenship",
          govIdNumber: "PSN-2024-00142",
          govIdFiles: [],
          verificationStatus: "pending",
          submissionDate: new Date().toISOString(),
          requestedUpdate: false,
        },
        {
          id: "W-1041",
          userId: "W-1041",
          userName: "Maria Santos",
          userRole: "worker",
          phone: "+63 917 234 5678",
          location: "Quezon City",
          govIdType: "citizenship",
          govIdNumber: "PSN-2024-00187",
          govIdFiles: [],
          verificationStatus: "verified",
          submissionDate: new Date(Date.now() - 86400000).toISOString(),
          requestedUpdate: false,
        },
        {
          id: "E-201",
          userId: "E-201",
          userName: "SunBuild Corp.",
          userRole: "employer",
          phone: "+63 912 100 2001",
          location: "Manila",
          govIdType: "business",
          govIdNumber: "BIR-2024-E0201",
          govIdFiles: [],
          verificationStatus: "pending",
          submissionDate: new Date().toISOString(),
          requestedUpdate: false,
        },
      ];
      setKYCRequests(dummyData);
      setLoading(false);
    }
  }, []);

  // Filter KYC requests
  const filteredRequests = kycRequests.filter((kyc) => {
    const q = search.toLowerCase();
    const matchSearch =
      kyc.userName.toLowerCase().includes(q) ||
      kyc.phone.includes(q) ||
      kyc.govIdNumber.toLowerCase().includes(q) ||
      kyc.location.toLowerCase().includes(q);
    
    const matchStatus = !filters?.status.length || filters.status.includes(kyc.verificationStatus);
    const matchRole = !filters?.skill.length || filters.skill.some(s => 
      s.toLowerCase() === kyc.userRole
    );
    
    return matchSearch && matchStatus && matchRole;
  });

  // Categorize requests
  const pendingRequests = filteredRequests.filter(k => k.verificationStatus === "pending");
  const verifiedRequests = filteredRequests.filter(k => k.verificationStatus === "verified");
  const rejectedRequests = filteredRequests.filter(k => k.verificationStatus === "rejected" || k.verificationStatus === "blocked");
  const updateRequests = filteredRequests.filter(k => k.requestedUpdate);

  // Pagination
  const getCurrentPageRequests = (requests: KYCRequest[]) => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    return requests.slice(startIndex, startIndex + itemsPerPage);
  };

  const totalPages = (requests: KYCRequest[]) => Math.ceil(requests.length / itemsPerPage);

  const handleApprove = async () => {
    if (!selectedKYC) return;
    
    try {
      const collectionName = selectedKYC.userRole === "worker" ? "workers" : "employers";
      await updateDoc(doc(db, collectionName, selectedKYC.userId), {
        verificationStatus: "verified",
        requestedUpdate: false,
        rejectionReason: "",
      });
      
      toast.success("KYC approved successfully");
      setSelectedKYC(null);
    } catch (error) {
      console.error("Error approving KYC:", error);
      toast.error("Failed to approve KYC");
    }
  };

  const handleReject = async () => {
    if (!selectedKYC || !rejectionReason.trim()) {
      toast.error("Please provide a rejection reason");
      return;
    }
    
    try {
      const collectionName = selectedKYC.userRole === "worker" ? "workers" : "employers";
      await updateDoc(doc(db, collectionName, selectedKYC.userId), {
        verificationStatus: "rejected",
        rejectionReason: rejectionReason,
      });
      
      toast.success("KYC rejected successfully");
      setSelectedKYC(null);
      setRejectionReason("");
    } catch (error) {
      console.error("Error rejecting KYC:", error);
      toast.error("Failed to reject KYC");
    }
  };

  const handleBlock = async () => {
    if (!selectedKYC) return;
    
    try {
      const collectionName = selectedKYC.userRole === "worker" ? "workers" : "employers";
      await updateDoc(doc(db, collectionName, selectedKYC.userId), {
        verificationStatus: "blocked",
        rejectionReason: "Account blocked by admin",
        requestedUpdate: false,
      });
      
      toast.success("Account blocked successfully");
      setSelectedKYC(null);
    } catch (error) {
      console.error("Error blocking account:", error);
      toast.error("Failed to block account");
    }
  };

  const handleRequestUpdate = async () => {
    if (!selectedKYC || !updateRequestReason.trim()) {
      toast.error("Please provide a reason for the update request");
      return;
    }
    
    try {
      const collectionName = selectedKYC.userRole === "worker" ? "workers" : "employers";
      await updateDoc(doc(db, collectionName, selectedKYC.userId), {
        verificationStatus: "pending",
        requestedUpdate: true,
        rejectionReason: updateRequestReason,
      });
      
      toast.success("Update request sent successfully");
      setSelectedKYC(null);
      setUpdateRequestReason("");
    } catch (error) {
      console.error("Error requesting update:", error);
      toast.error("Failed to request update");
    }
  };

  const getTabRequests = () => {
    switch (activeTab) {
      case "pending": return pendingRequests;
      case "verified": return verifiedRequests;
      case "rejected": return rejectedRequests;
      case "updates": return updateRequests;
      default: return pendingRequests;
    }
  };

  const currentTabRequests = getTabRequests();
  const paginatedRequests = getCurrentPageRequests(currentTabRequests);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-sm font-semibold text-foreground">KYC Updates</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Manage Government ID verification requests</p>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant="outline" className="text-xs">
            {pendingRequests.length} Pending
          </Badge>
          <Badge variant="outline" className="text-xs text-emerald-400">
            {verifiedRequests.length} Verified
          </Badge>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={(v) => {
        setActiveTab(v as any);
        setCurrentPage(1);
      }}>
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="pending" className="flex items-center gap-2">
            <Clock className="w-3 h-3" />
            Pending
            {pendingRequests.length > 0 && (
              <Badge variant="secondary" className="text-[10px] h-4 px-1">
                {pendingRequests.length}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="verified" className="flex items-center gap-2">
            <CheckCircle className="w-3 h-3" />
            Verified
            {verifiedRequests.length > 0 && (
              <Badge variant="secondary" className="text-[10px] h-4 px-1">
                {verifiedRequests.length}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="rejected" className="flex items-center gap-2">
            <XCircle className="w-3 h-3" />
            Rejected/Blocked
            {rejectedRequests.length > 0 && (
              <Badge variant="secondary" className="text-[10px] h-4 px-1">
                {rejectedRequests.length}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="updates" className="flex items-center gap-2">
            <RefreshCw className="w-3 h-3" />
            Updates
            {updateRequests.length > 0 && (
              <Badge variant="secondary" className="text-[10px] h-4 px-1">
                {updateRequests.length}
              </Badge>
            )}
          </TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-4">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <div className="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin" />
            </div>
          ) : paginatedRequests.length === 0 ? (
            <Card className="p-8 text-center">
              <ShieldCheck className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
              <p className="text-sm text-muted-foreground">No KYC requests found</p>
            </Card>
          ) : (
            <div className="space-y-3">
              {paginatedRequests.map((kyc) => {
                const StatusIcon = statusIcon[kyc.verificationStatus];
                return (
                  <Card key={kyc.id} className="p-4 hover:border-primary/30 transition-colors cursor-pointer" onClick={() => setSelectedKYC(kyc)}>
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                        {kyc.userRole === "worker" ? (
                          <User className="w-5 h-5 text-primary" />
                        ) : (
                          <Building2 className="w-5 h-5 text-primary" />
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <p className="text-sm font-medium text-foreground">{kyc.userName}</p>
                          <Badge variant="outline" className="text-[10px] capitalize">
                            {kyc.userRole}
                          </Badge>
                          {kyc.requestedUpdate && (
                            <Badge variant="secondary" className="text-[10px]">
                              <RefreshCw className="w-3 h-3 mr-1" />
                              Update
                            </Badge>
                          )}
                        </div>
                        <div className="flex items-center gap-3 mt-1 text-xs text-muted-foreground">
                          <span className="flex items-center gap-1">
                            <Phone className="w-3 h-3" />
                            {kyc.phone}
                          </span>
                          <span className="flex items-center gap-1">
                            <MapPin className="w-3 h-3" />
                            {kyc.location}
                          </span>
                          <span className="flex items-center gap-1">
                            <FileText className="w-3 h-3" />
                            {kyc.govIdType}
                          </span>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <Badge className={`text-xs ${statusStyle[kyc.verificationStatus]}`}>
                          <StatusIcon className="w-3 h-3 mr-1" />
                          {kyc.verificationStatus}
                        </Badge>
                        <ChevronRight className="w-4 h-4 text-muted-foreground" />
                      </div>
                    </div>
                  </Card>
                );
              })}

              {/* Pagination */}
              {totalPages(currentTabRequests) > 1 && (
                <div className="flex items-center justify-between mt-4">
                  <p className="text-xs text-muted-foreground">
                    Showing {(currentPage - 1) * itemsPerPage + 1} to {Math.min(currentPage * itemsPerPage, currentTabRequests.length)} of {currentTabRequests.length}
                  </p>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                      disabled={currentPage === 1}
                    >
                      <ChevronLeft className="w-4 h-4" />
                    </Button>
                    <span className="text-xs text-muted-foreground">
                      Page {currentPage} of {totalPages(currentTabRequests)}
                    </span>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setCurrentPage(p => Math.min(totalPages(currentTabRequests), p + 1))}
                      disabled={currentPage === totalPages(currentTabRequests)}
                    >
                      <ChevronRight className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              )}
            </div>
          )}
        </TabsContent>
      </Tabs>

      {/* KYC Review Dialog */}
      <Dialog open={!!selectedKYC} onOpenChange={() => setSelectedKYC(null)}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <ShieldCheck className="w-5 h-5" />
              KYC Review
            </DialogTitle>
          </DialogHeader>
          
          {selectedKYC && (
            <div className="space-y-6">
              {/* User Information */}
              <div className="space-y-4">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
                    {selectedKYC.userRole === "worker" ? (
                      <User className="w-8 h-8 text-primary" />
                    ) : (
                      <Building2 className="w-8 h-8 text-primary" />
                    )}
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-foreground">{selectedKYC.userName}</h3>
                    <div className="flex items-center gap-2 mt-1">
                      <Badge variant="outline" className="capitalize">
                        {selectedKYC.userRole}
                      </Badge>
                      <Badge className={statusStyle[selectedKYC.verificationStatus]}>
                        {selectedKYC.verificationStatus}
                      </Badge>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-1">
                    <p className="text-xs text-muted-foreground">Phone Number</p>
                    <p className="text-sm text-foreground flex items-center gap-2">
                      <Phone className="w-4 h-4" />
                      {selectedKYC.phone}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-xs text-muted-foreground">Location</p>
                    <p className="text-sm text-foreground flex items-center gap-2">
                      <MapPin className="w-4 h-4" />
                      {selectedKYC.location}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-xs text-muted-foreground">Government ID Type</p>
                    <p className="text-sm text-foreground flex items-center gap-2">
                      <FileText className="w-4 h-4" />
                      {selectedKYC.govIdType}
                    </p>
                  </div>
                  <div className="space-y-1">
                    <p className="text-xs text-muted-foreground">Government ID Number</p>
                    <p className="text-sm text-foreground font-mono">{selectedKYC.govIdNumber}</p>
                  </div>
                  <div className="space-y-1 col-span-2">
                    <p className="text-xs text-muted-foreground">Submission Date</p>
                    <p className="text-sm text-foreground flex items-center gap-2">
                      <Clock className="w-4 h-4" />
                      {new Date(selectedKYC.submissionDate).toLocaleString()}
                    </p>
                  </div>
                </div>
              </div>

              {/* Government ID Documents */}
              <div className="space-y-2">
                <p className="text-sm font-medium text-foreground">Government ID Documents</p>
                {selectedKYC.govIdFiles.length > 0 ? (
                  <div className="grid grid-cols-2 gap-3">
                    {selectedKYC.govIdFiles.map((file, index) => (
                      <div key={index} className="border border-border rounded-lg p-3">
                        <div className="aspect-video bg-muted rounded flex items-center justify-center">
                          <FileText className="w-8 h-8 text-muted-foreground" />
                        </div>
                        <p className="text-xs text-muted-foreground mt-2 truncate">{file}</p>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-muted-foreground">No documents uploaded</p>
                )}
              </div>

              {/* Previous KYC Information (if update) */}
              {selectedKYC.previousKYC && (
                <div className="space-y-2">
                  <p className="text-sm font-medium text-foreground flex items-center gap-2">
                    <RefreshCw className="w-4 h-4" />
                    Previous KYC Information
                  </p>
                  <div className="bg-muted/50 rounded-lg p-4 space-y-2">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-xs text-muted-foreground">Previous ID Type</p>
                        <p className="text-sm text-foreground">{selectedKYC.previousKYC.govIdType}</p>
                      </div>
                      <div>
                        <p className="text-xs text-muted-foreground">Previous ID Number</p>
                        <p className="text-sm text-foreground font-mono">{selectedKYC.previousKYC.govIdNumber}</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Rejection Reason (if rejected) */}
              {selectedKYC.rejectionReason && (
                <div className="space-y-2">
                  <p className="text-sm font-medium text-foreground flex items-center gap-2">
                    <AlertCircle className="w-4 h-4" />
                    Rejection/Block Reason
                  </p>
                  <div className="bg-rose-500/10 border border-rose-500/20 rounded-lg p-4">
                    <p className="text-sm text-rose-400">{selectedKYC.rejectionReason}</p>
                  </div>
                </div>
              )}

              {/* Admin Actions */}
              <div className="border-t border-border pt-4">
                <p className="text-sm font-medium text-foreground mb-3">Admin Actions</p>
                <div className="flex flex-wrap gap-2">
                  {selectedKYC.verificationStatus === "pending" && (
                    <>
                      <Button onClick={handleApprove} className="flex items-center gap-2">
                        <CheckCircle className="w-4 h-4" />
                        Approve / Verify
                      </Button>
                      <Button onClick={handleBlock} variant="destructive" className="flex items-center gap-2">
                        <Ban className="w-4 h-4" />
                        Block Account
                      </Button>
                      <Button onClick={() => {
                        if (confirm("Are you sure you want to reject this KYC?")) {
                          // Show rejection reason input
                          setRejectionReason("");
                        }
                      }} variant="outline" className="flex items-center gap-2">
                        <XCircle className="w-4 h-4" />
                        Reject KYC
                      </Button>
                    </>
                  )}
                  
                  {selectedKYC.verificationStatus === "verified" && (
                    <Button onClick={handleRequestUpdate} variant="outline" className="flex items-center gap-2">
                      <MessageSquare className="w-4 h-4" />
                      Request Update/Correction
                    </Button>
                  )}

                  {selectedKYC.verificationStatus === "rejected" && (
                    <Button onClick={handleApprove} variant="outline" className="flex items-center gap-2">
                      <RefreshCw className="w-4 h-4" />
                      Approve After Review
                    </Button>
                  )}
                </div>

                {/* Rejection Reason Input */}
                {selectedKYC.verificationStatus === "pending" && (
                  <div className="mt-4 space-y-2">
                    <p className="text-xs text-muted-foreground">Rejection Reason (required for rejection)</p>
                    <Textarea
                      placeholder="Enter reason for rejection..."
                      value={rejectionReason}
                      onChange={(e) => setRejectionReason(e.target.value)}
                      className="min-h-[80px]"
                    />
                    <Button 
                      onClick={handleReject} 
                      variant="destructive" 
                      size="sm"
                      disabled={!rejectionReason.trim()}
                    >
                      Submit Rejection
                    </Button>
                  </div>
                )}

                {/* Update Request Input */}
                {selectedKYC.verificationStatus === "verified" && (
                  <div className="mt-4 space-y-2">
                    <p className="text-xs text-muted-foreground">Reason for Update Request</p>
                    <Textarea
                      placeholder="Enter reason for requesting KYC update..."
                      value={updateRequestReason}
                      onChange={(e) => setUpdateRequestReason(e.target.value)}
                      className="min-h-[80px]"
                    />
                    <Button 
                      onClick={handleRequestUpdate} 
                      size="sm"
                      disabled={!updateRequestReason.trim()}
                    >
                      Submit Update Request
                    </Button>
                  </div>
                )}
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
