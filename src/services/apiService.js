//const BASE_URL = "http://localhost/oddproject/api";
const BASE_URL = "https://prasperascons.com/app/api";

export const apiService = {
  baseUrl: BASE_URL,

  // LOGIN
  async login(email, password) {
    try {
      const response = await fetch(`${this.baseUrl}/login.php`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
        credentials: "include",
      });
      const data = await response.json();
      if (!response.ok || data.code !== 200) {
        throw new Error(data.message || "Login failed");
      }
      return data;
    } catch (error) {
      return { code: 500, message: error.message };
    }
  },

  // REGISTER
  async register(userData) {
    console.log("Data click",userData);
    
    const response = await fetch(`${this.baseUrl}/register.php`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(userData),
      credentials: "include",
    });
    return response.json();
  },

  // GET LOGGED-IN USER
  async getUser() {
    try {
      const response = await fetch(`${this.baseUrl}/user.php`, {
        method: "GET",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
      });
      const data = await response.json();
      if (!response.ok || data.code !== 200) {
        throw new Error(data.message || "User not authenticated");
      }
      return data;
    } catch (error) {
      console.error("User not authenticated or session expired");
      return { code: 401, user: null, message: error.message };
    }
  },

  // GET ALL USERS
  async getAllUsers() {
    try {
      const response = await fetch(`${this.baseUrl}/get_users.php`, {
        method: "GET",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
      });
      const data = await response.json();
      if (!response.ok || data.code !== 200) {
        throw new Error(data.message || "Failed to fetch users");
      }
      return data;
    } catch (error) {
      console.error("Failed to fetch users:", error);
      return { code: 500, users: [] };
    }
  },

  // DELETE USER
  async deleteUser(userId) {
    try {
      const response = await fetch(`${this.baseUrl}/delete_user.php`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: userId }),
        credentials: "include",
      });
      const data = await response.json();
      return data;
    } catch (error) {
      console.error("Failed to delete user:", error);
      return { code: 500, message: error.message };
    }
  },

  // TOGGLE USER STATUS
  async toggleUserStatus(userId, status) {
    try {
      const response = await fetch(`${this.baseUrl}/update-status.php`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: userId, status }),
        credentials: "include",
      });
      const data = await response.json();
      return data;
    } catch (error) {
      console.error("Failed to toggle status:", error);
      return { code: 500, message: error.message };
    }
  },

  // Get data for Dashboard Statistic
async getDashboardData() {
  try {
    const response = await fetch(`${this.baseUrl}/dashboard_data.php`, {
      method: "GET",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
    });
   
    const data = await response.json();
     console.log('Dashbaord Data', data);

    if (!response.ok || data.code !== 200) {
      throw new Error(data.message || "Failed to fetch dashboard data");
    }

    return data;
  } catch (error) {
    console.error("Dashboard API error:", error.message);
    return { code: 500, message: error.message };
  }
},

 // Get notification
async getNotifications() {
  try {
    const response = await fetch(`${this.baseUrl}/get_notifications.php`, {
      method: "GET",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
    });
   
    const data = await response.json();
     console.log('Notification Data', data);

    if (!response.ok || data.code !== 200) {
      throw new Error(data.message || "Failed to fetch dashboard data");
    }

    return data;
  } catch (error) {
    console.error("Notification API error:", error.message);
    return { code: 500, message: error.message };
  }
},

// Manage course

async getCourses() {
    try {
      const res = await fetch(`${BASE_URL}/courses_api.php?action=list`, {
        credentials: "include", // send session cookies
      });
      return await res.json();
    } catch (err) {
      console.error("API getCourses error:", err);
      return { code: 500, message: "Failed to fetch courses" };
    }
  },

  // ---------------- SAVE COURSE ----------------
  
 async saveCourse(course) {
  try {
    const formData = new FormData();
    for (const key in course) {
      if (course[key] !== null && course[key] !== undefined) {
        formData.append(key, course[key]);
      }
    }

    // Debug: see contents of FormData
    for (let pair of formData.entries()) {
      console.log(pair[0], pair[1]);
    }

    const res = await fetch(`${BASE_URL}/courses_api.php?action=save`, {
      method: "POST",
      body: formData,
      credentials: "include",
    });

    const data = await res.json();
    return data;

  } catch (err) {
    console.error("API saveCourse error:", err);
    return { code: 500, message: "Failed to save course" };
  }
},

  // ---------------- UPDATE COURSE ----------------
  async updateCourse(course) {
    try {
      const formData = new FormData();
      for (const key in course) {
        if (course[key] !== null && course[key] !== undefined) {
          formData.append(key, course[key]);
        }
      }

      const res = await fetch(`${BASE_URL}/courses_api.php?action=update`, {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      return await res.json();
    } catch (err) {
      console.error("API updateCourse error:", err);
      return { code: 500, message: "Failed to update course" };
    }
  },

  // ---------------- DELETE COURSE ----------------
  async deleteCourse(id) {
    try {
      const formData = new FormData();
      formData.append("id", id);

      const res = await fetch(`${BASE_URL}/courses_api.php?action=delete`, {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      return await res.json();
    } catch (err) {
      console.error("API deleteCourse error:", err);
      return { code: 500, message: "Failed to delete course" };
    }
  },
// ---------------- ASSIGN COURSE TO USER ----------------
async assignCourse(user_id, course_id) {
  if (!user_id || !course_id) {
    return { code: 400, message: "User ID and Course ID are required" };
  }

  try {
    const res = await fetch(`${this.baseUrl}/courses_api.php?action=assign`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ user_id, course_id }),
    });

    const data = await res.json();

    // Handle backend responses: success, duplicate, failure
    if (data.code === 200) {
      return { code: 200, message: data.message || "Course assigned to user" };
    } else if (data.code === 409) {
      return { code: 409, message: data.message || "User already enrolled" };
    } else if (data.code === 400) {
      return { code: 400, message: data.message || "Invalid request" };
    } else {
      return { code: 500, message: data.message || "Failed to assign course" };
    }
  } catch (error) {
    console.error("API assignCourse error:", error);
    return { code: 500, message: "Failed to assign course" };
  }
},

// ---------------- REMOVE ENROLLMENT ----------------
async removeEnrollment(enrollment_id) {
  try {
    const res = await fetch(`${this.baseUrl}/courses_api.php?action=remove-user-course`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ enrollment_id }),
    });

    return await res.json();
  } catch (error) {
    console.error("API removeEnrollment error:", error);
    return { code: 500, message: "Failed to remove enrollment" };
  }
},

// ---------------- USER COURSES ----------------
async getUserCourses() {
  try {
    const res = await fetch(`${this.baseUrl}/courses_api.php?action=user_courses`, {
      method: "GET",
      headers: { "Content-Type": "application/json" },
      credentials: "include", // keep session
    });

    return await res.json();
  } catch (error) {
    console.error("API getUserCourses error:", error);
    return { code: 500, courses: [] };
  }
},
// ---------------- GET ALL USERS WITH COURSES ----------------
async getAllUserCourses() {
  try {
    const res = await fetch(`${this.baseUrl}/courses_api.php?action=all_user_courses`, {
      method: "GET",
      headers: { "Content-Type": "application/json" },
      credentials: "include", // keep session
    });

    return await res.json(); // expects { code: 200, enrollments: [...] }
  } catch (error) {
    console.error("API getAllUserCourses error:", error);
    return { code: 500, enrollments: [] };
  }
},

 async updateAssign(enrollment_id, user_id, course_id) {
    try {
      const res = await fetch(`${this.baseUrl}/courses_api.php?action=update_assign`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ id: Number(enrollment_id), user_id: Number(user_id), course_id: Number(course_id) }),
      });
      return await res.json();
    } catch (err) { return { code: 500, message: "Failed to update course" }; }
  },

  //************** Module Management */

  async getModules() {
    try {
      const res = await fetch(`${BASE_URL}/courses_api.php?action=list_modules`, {
        credentials: "include", // send session cookies
      });
      return await res.json();
    } catch (err) {
      console.error("API get module error:", err);
      return { code: 500, message: "Failed to fetch module" };
    }
  },

  // save module
async saveModule(module) {
  try {
    const formData = new FormData();
    for (const key in module) {
      // Use 'module', not 'course'
      if (module[key] !== null && module[key] !== undefined) {
        formData.append(key, module[key]);
      }
    }

    // Debug: see contents of FormData
    for (let pair of formData.entries()) {
      console.log(pair[0], pair[1]);
    }

    const res = await fetch(`${BASE_URL}/courses_api.php?action=save_module`, {
      method: "POST",
      body: formData,
      credentials: "include",
    });

    const data = await res.json();
    return data;

  } catch (err) {
    console.error("API saveModule error:", err);
    return { code: 500, message: "Failed to save module" };
  }
},

async deleteModule(id) {
    try {
      const formData = new FormData();
      formData.append("id", id);

      const res = await fetch(`${BASE_URL}/courses_api.php?action=delete_module`, {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      return await res.json();
    } catch (err) {
      console.error("API deleteModule error:", err);
      return { code: 500, message: "Failed to delete module" };
    }
  },

  async updateModule(course) {
    try {
      const formData = new FormData();
      for (const key in course) {
        if (course[key] !== null && course[key] !== undefined) {
          formData.append(key, course[key]);
        }
      }

      const res = await fetch(`${BASE_URL}/courses_api.php?action=update_module`, {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      return await res.json();
    } catch (err) {
      console.error("API updateModule error:", err);
      return { code: 500, message: "Failed to update module" };
    }
  },

  // ************** MODULE ATTACHMENTS **************

// GET ATTACHMENTS

 async getModuleAttachments() {
  try {

    const response = await fetch(
      `${BASE_URL}/courses_api.php?action=list_module_attachments`,
      {
        method: "GET",
        credentials: "include"
      }
    );

    const data = await response.json();

    console.log("Attachments API RESPONSE:", data);

    return data;

  } catch (error) {
    console.error("API Error:", error);
    return { code: 500, attachments: [] };
  }
},

// SAVE ATTACHMENT
async saveModuleAttachment(attachment) {
  console.log("data to update", attachment);
  try {
    const formData = new FormData();

    for (const key in attachment) {
      if (attachment[key] !== null && attachment[key] !== undefined) {
        formData.append(key, attachment[key]);
      }
    }
    console.log("Data",formData );
    const res = await fetch(`${BASE_URL}/courses_api.php?action=save_module_attachment`, {
      method: "POST",
      body: formData,
      credentials: "include",
    });

    return await res.json();

  } catch (err) {
    console.error("API saveModuleAttachment error:", err);
    return { code: 500, message: "Failed to save attachment" };
  }
},

// UPDATE ATTACHMENT
async updateModuleAttachment(attachment) {
  console.log("data to update", attachment);
  try {
    const formData = new FormData();

    for (const key in attachment) {
      if (attachment[key] !== null && attachment[key] !== undefined) {
        formData.append(key, attachment[key]);
      }
    }

    const res = await fetch(`${BASE_URL}/courses_api.php?action=update_module_attachment`, {
      method: "POST",
      body: formData,
      credentials: "include",
    });

    return await res.json();

  } catch (err) {
    console.error("API updateModuleAttachment error:", err);
    return { code: 500, message: "Failed to update attachment" };
  }
},



// DELETE ATTACHMENT
async deleteModuleAttachment(id) {
  try {
    const formData = new FormData();
    formData.append("id", id);

    const res = await fetch(`${BASE_URL}/courses_api.php?action=delete_module_attachment`, {
      method: "POST",
      body: formData,
      credentials: "include",
    });

    return await res.json();

  } catch (err) {
    console.error("API deleteModuleAttachment error:", err);
    return { code: 500, message: "Failed to delete attachment" };
  }
},


};