-- Add unique constraint to verification_criteria table
ALTER TABLE verification_criteria
ADD CONSTRAINT verification_criteria_project_id_unique UNIQUE (project_id);
