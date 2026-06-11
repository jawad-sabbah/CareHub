export const validateEmail = (email) => {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error("Invalid email format");
  }
};

export const validatePhone = (phone_number) => {
  if (!/^\d{8}$/.test(phone_number)) {
    throw new Error("Phone number must be 8 digits");
  }
};

export const validateGender = (gender) => {
  if (!["M", "F"].includes(gender)) {
    throw new Error("Gender must be M or F");
  }
};

export const validateDateOfBirth = (date_of_birth) => {
  if (isNaN(new Date(date_of_birth).getTime())) {
    throw new Error("Invalid date of birth format");
  }
};