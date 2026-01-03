-- ============================================
-- Zen Origami - Supabase Database Schema
-- ============================================
--
-- Anleitung:
-- 1. Supabase Dashboard öffnen (https://supabase.com)
-- 2. Dein Projekt öffnen
-- 3. SQL Editor (links im Menü)
-- 4. New Query
-- 5. Diesen Code komplett kopieren & pasten
-- 6. Run (F5 oder Play Button)
--

-- ============================================
-- Game State Table
-- ============================================

CREATE TABLE game_states (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Currencies (aktuelle Werte)
    currency_drop INTEGER DEFAULT 0,
    currency_pearl INTEGER DEFAULT 0,
    currency_leaf INTEGER DEFAULT 0,

    -- Total Collected (lifetime stats)
    total_collected_drop INTEGER DEFAULT 0,
    total_collected_pearl INTEGER DEFAULT 0,
    total_collected_leaf INTEGER DEFAULT 0,

    -- Upgrades (Level für jeden Upgrade-Typ)
    upgrade_speed INTEGER DEFAULT 0,
    upgrade_collection_radius INTEGER DEFAULT 0,
    upgrade_drop_rate INTEGER DEFAULT 0,
    upgrade_rain_collector INTEGER DEFAULT 0,

    -- One-time items (Add-ons & Companions)
    addon_flag BOOLEAN DEFAULT FALSE,
    skin_swan BOOLEAN DEFAULT FALSE,
    companion_fish BOOLEAN DEFAULT FALSE,
    companion_bird BOOLEAN DEFAULT FALSE,

    -- Active cosmetics
    active_skin TEXT DEFAULT 'defaultBoat',

    -- Meta stats
    total_upgrades_purchased INTEGER DEFAULT 0,
    play_time INTEGER DEFAULT 0,
    login_streak INTEGER DEFAULT 0,

    -- Prestige system
    prestige_level INTEGER DEFAULT 0,
    prestige_zen_points INTEGER DEFAULT 0,
    prestige_total_prestiges INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_visit TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    UNIQUE(user_id)
);

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- Enable RLS
ALTER TABLE game_states ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read own game state
CREATE POLICY "Users can read own game state"
    ON game_states FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert own game state
CREATE POLICY "Users can insert own game state"
    ON game_states FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update own game state
CREATE POLICY "Users can update own game state"
    ON game_states FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- Triggers & Functions
-- ============================================

-- Auto-update updated_at timestamp on UPDATE
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER game_states_updated_at
    BEFORE UPDATE ON game_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================
-- Indexes (für Performance)
-- ============================================

-- Index auf user_id für schnellere Lookups
CREATE INDEX idx_game_states_user_id ON game_states(user_id);

-- Index auf updated_at für Sortierung
CREATE INDEX idx_game_states_updated_at ON game_states(updated_at DESC);

-- ============================================
-- Test Query (optional - zum Testen)
-- ============================================

-- Zeige alle Tables
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Zeige game_states Schema
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'game_states';

-- ============================================
-- Fertig! ✅
-- ============================================
--
-- Nächste Schritte:
-- 1. Zurück zu Xcode
-- 2. Supabase SDK hinzufügen
-- 3. AuthService + DatabaseService kopieren
-- 4. Environment Variables setzen
-- 5. Build & Run!
--
