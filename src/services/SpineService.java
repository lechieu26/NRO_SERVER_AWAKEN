package services;

import network.Message;
import player.Player;
import utils.Logger;

/**
 * Service xử lý các packet liên quan đến Spine Skin
 * @author Antigravity
 */
public class SpineService {

    private static SpineService instance;

    public static SpineService gI() {
        if (instance == null) {
            instance = new SpineService();
        }
        return instance;
    }

    /**
     * Gửi dữ liệu khởi tạo Spine cho một người chơi cụ thể (thường khi họ mới vào map)
     */
    public void sendSpineInitData(Player receiver, Player target, int skinId) {
        if (skinId <= 0 || receiver == null || target == null) return;
        Message msg = null;
        try {
            msg = new Message(-48);
            msg.writer().writeByte(0); // SPINE_INIT_DATA
            msg.writer().writeInt((int) target.id);
            msg.writer().writeBoolean(true); // useSpine
            msg.writer().writeInt(skinId);
            msg.writer().writeBoolean(true); // loop
            msg.writer().writeByte(1); // scaleX
            receiver.sendMessage(msg);
        } catch (Exception e) {
            Logger.logException(SpineService.class, e);
        } finally {
            if (msg != null) {
                msg.cleanup();
            }
        }
    }

    /**
     * Gửi dữ liệu khởi tạo Spine cho tất cả người chơi trong map của player
     */
    public void sendSpineInitData(Player player, int skinId) {
        if (skinId <= 0 || player == null) return;
        Message msg = null;
        try {
            msg = new Message(-48);
            msg.writer().writeByte(0); // SPINE_INIT_DATA
            msg.writer().writeInt((int) player.id);
            msg.writer().writeBoolean(true); // useSpine
            msg.writer().writeInt(skinId);
            msg.writer().writeBoolean(true); // loop
            msg.writer().writeByte(1); // scaleX
            Service.gI().sendMessAllPlayerInMap(player, msg);
        } catch (Exception e) {
            Logger.logException(SpineService.class, e);
        } finally {
            if (msg != null) {
                msg.cleanup();
            }
        }
    }

    /**
     * Gửi hiệu ứng Spine skill (animation biến hình, v.v.)
     */
    public void sendSpineSkillEffect(Player player, String skeletonPath, String animation, int durationMs) {
        if (player == null) {
            return;
        }
        Message msg = null;
        try {
            msg = new Message(-48);
            msg.writer().writeByte(9); // SPINE_SKILL_EFFECT
            msg.writer().writeInt((int) player.id);
            msg.writer().writeUTF(skeletonPath);
            msg.writer().writeUTF(animation);
            msg.writer().writeShort((short) durationMs);
            Service.gI().sendMessAllPlayerInMap(player, msg);
        } catch (Exception e) {
            Logger.logException(SpineService.class, e);
        } finally {
            if (msg != null) {
                msg.cleanup();
            }
        }
    }

    /**
     * Gửi packet bật/tắt Spine Skin
     */
    public void sendSpineToggle(Player player, boolean useSpine, int skinId) {
        Message msg = null;
        try {
            msg = new Message(-48);
            msg.writer().writeByte(7); // SPINE_TOGGLE
            msg.writer().writeInt((int) player.id);
            msg.writer().writeBoolean(useSpine);
            if (useSpine) {
                msg.writer().writeInt(skinId);
            }
            Service.gI().sendMessAllPlayerInMap(player, msg);
        } catch (Exception e) {
            Logger.logException(SpineService.class, e);
        } finally {
            if (msg != null) {
                msg.cleanup();
            }
        }
    }
}
