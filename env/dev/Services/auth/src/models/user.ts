import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUser {
  name: string;
  email: string;
  password: string;
  role: 'user' | 'admin';
  avatar?: string;
  addresses?: {
    street: string;
    city: string;
    state: string;
    country: string;
    zipCode: string;
  }[];
  createdAt: Date;
  updatedAt: Date;
  matchPassword(entered: string): Promise<boolean>;
}

const userSchema = new mongoose.Schema<IUser>(
  {
    name: { type: String, required: [true, 'Please provide your name'] },
    email: {
      type: String,
      required: [true, 'Please provide your email'],
      unique: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: [true, 'Please provide a password'],
      minlength: 8,
      select: false,
    },
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    avatar: { type: String },
    addresses: [
      {
        street: String,
        city: String,
        state: String,
        country: String,
        zipCode: String,
      },
    ],
  },
  { timestamps: true }
);

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

userSchema.methods.matchPassword = async function (entered: string) {
  return bcrypt.compare(entered, this.password);
};

export default mongoose.models.User || mongoose.model<IUser>('User', userSchema);
