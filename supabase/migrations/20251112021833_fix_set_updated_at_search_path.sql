/*
  # Fix Function Search Path Security Issue

  1. Changes
    - Drop and recreate `set_updated_at()` function with immutable search_path
    - Sets search_path to empty string to prevent malicious schema injection
    - Adds SECURITY DEFINER with proper search_path configuration

  2. Security
    - Prevents search path manipulation attacks
    - Ensures function only accesses objects in the intended schema
    - Follows PostgreSQL security best practices for SECURITY DEFINER functions

  ## Important Notes
  - The search_path is set at function creation time and cannot be changed at runtime
  - This prevents attackers from injecting malicious schemas into the search path
*/

-- Drop existing function
DROP FUNCTION IF EXISTS public.set_updated_at() CASCADE;

-- Recreate function with secure search_path
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  new.updated_at = now();
  RETURN new;
END;
$$;

-- Recreate trigger for updated_at
DROP TRIGGER IF EXISTS trg_set_updated_at ON public.dcf_leads;
CREATE TRIGGER trg_set_updated_at
  BEFORE UPDATE ON public.dcf_leads
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();
