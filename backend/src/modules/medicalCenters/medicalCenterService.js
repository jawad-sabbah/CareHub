import medicalCenterRepository from "./medicalCenterRepository.js";

class MedicalCenterService {
  async getAllMedicalCenters() {
    const centers = await medicalCenterRepository.getAllMedicalCenters();
    if (!centers || centers.length === 0) {
      throw new Error("No medical centers found");
    }

    return centers.map((center) => ({
      id: center.id,
      name: center.name,
      type: center.type,
      address: center.address,
      phone: center.phone,
      is_open: center.is_open,
    }));
  }

  async getMedicalCenterById(id) {
    const center = await medicalCenterRepository.getMedicalCenterById(id);

    if (!center) {
      throw new Error("Medical center not found");
    }

    let status = "";
    if (center.is_open === false) {
      status = "closed";
    } else {
      status = "open";
    }

    return {
      id: center.id,
      name: center.name,
      type: center.type,
      address: center.address,
      phone: center.phone,
      image_url: center.image_url,
      description: center.description,
      email: center.email,
      is_open: status,
    };
  }

  async getMedicalCentersByType(type) {
    const allowedTypes = ["hospital", "clinic", "lab"];

    if (!allowedTypes.includes(type)) {
      throw new Error("Invalid medical center type");
    }

    const centers =
      await medicalCenterRepository.getMedicalCentersByType(type);

    return centers.map((center) => ({
      id: center.id,
      name: center.name,
      type: center.type,
      address: center.address,
      phone: center.phone,
      status: center.is_open === false ? "closed" : "open",
    }));
  }

  async searchMedicalCenters(searchTerm) {
    if (!searchTerm || searchTerm.trim() === "") {
      throw new Error("Search term is required");
    }

    const centers =
      await medicalCenterRepository.searchMedicalCenters(searchTerm.trim());

    return centers.map((center) => ({
      id: center.id,
      name: center.name,
      type: center.type,
      address: center.address,
      phone: center.phone,
      status: center.is_open === false ? "closed" : "open",
    }));
  }
}

export default new MedicalCenterService();