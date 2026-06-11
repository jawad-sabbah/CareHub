export const validateEmail = (email) => {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error("Invalid email format");
  }
};

export const validatePhone = (phone) => {
  if (!/^\d{8}$/.test(phone)) {
    throw new Error("Phone number must be 8 digits");
  }
};

export const validateGender = (gender) => {
  if (!["M", "F"].includes(gender)) {
    throw new Error("Gender must be M or F");
  }
};